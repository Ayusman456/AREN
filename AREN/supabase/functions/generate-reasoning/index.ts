import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    })
  }

  try {
    const bodyText = await req.text()
    console.log("Raw body:", bodyText)

    const { outfit_id } = JSON.parse(bodyText)
    if (!outfit_id) return error("outfit_id required")

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    )

    const { data: outfit, error: fetchErr } = await supabase
      .from("daily_outfits")
      .select("id, occasion, top_id, bottom_id, shoes_id")
      .eq("id", outfit_id)
      .single()

      console.log("fetchErr:", JSON.stringify(fetchErr))
      console.log("outfit:", JSON.stringify(outfit))
    if (fetchErr || !outfit) return error("outfit not found")

    const itemIds = [outfit.top_id, outfit.bottom_id, outfit.shoes_id].filter(Boolean)
    const { data: items } = await supabase
      .from("clothing_items")
      .select("id, color, weight_category, formality_score")
      .in("id", itemIds)

    const top    = items?.find((i: any) => i.id === outfit.top_id)
    const bottom = items?.find((i: any) => i.id === outfit.bottom_id)
    const shoes  = items?.find((i: any) => i.id === outfit.shoes_id)

    const prompt = buildPrompt({ occasion: outfit.occasion, top, bottom, shoes })

      const aiRes = await fetch("https://api.groq.com/openai/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${Deno.env.get("GROQ_API_KEY")}`
        },
        body: JSON.stringify({
          model: "llama-3.1-8b-instant",
          messages: [{ role: "user", content: prompt }],
          max_tokens: 50
        })
      })

      const aiData = await aiRes.json()
      const reasoning = aiData.choices?.[0]?.message?.content?.trim()

    if (!reasoning) return error("no reasoning returned")

    await supabase
      .from("daily_outfits")
      .update({ reasoning_text: reasoning })
      .eq("id", outfit_id)

    return new Response(JSON.stringify({ reasoning }), {
      headers: { "Content-Type": "application/json" }
    })

  } catch (e) {
    return error(e.message)
  }
})

function buildPrompt(outfit: any): string {
  const { occasion, top, bottom, shoes } = outfit
  return `You are a concise fashion stylist. Write one sentence, strictly 6 words maximum, explaining why this outfit works.
Occasion: ${occasion ?? "everyday"}.
Top: ${top?.color ?? "neutral"}, formality ${top?.formality_score ?? 5}/10.
Bottom: ${bottom?.color ?? "neutral"}, formality ${bottom?.formality_score ?? 5}/10.
Shoes: ${shoes?.color ?? "neutral"}.
Rules: sentence case, no quotes, no punctuation at end, conversational not editorial.
Output only the sentence.`
}

function error(msg: string) {
  return new Response(JSON.stringify({ error: msg }), {
    status: 400,
    headers: { "Content-Type": "application/json" }
  })
}
