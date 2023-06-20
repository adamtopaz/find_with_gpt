import LeanPinecone
import LeanGpt
import LeanEmbedding

elab "#find" n:name : command => do
  let query := n.getName
  let res ← EmbeddingM.getIndexedEmbeddings #[toString query] |>.run
  let res := res.map fun e => e.embedding
  if h : 0 < res.size then 
    let res := res[0]
    let query : Pinecone.Query := {
      topK := 10
      vector := res
      nmspace := "name"
    }
    let res ← PineconeM.query query |>.run 
    let res := res.mtches.map fun m => (m.score, m.metadata)
    for r in res do
      let some metadata := r.2 | continue
      let .ok moduleName := metadata.getObjValAs? String "module" | continue
      let .ok declName := metadata.getObjValAs? String "name" | continue
      let .ok declType := metadata.getObjValAs? String "type" | continue
      let score := r.1
      IO.println "---"
      IO.println ""
      IO.println s!"Score:
{score}"
      IO.println ""
      IO.println s!"Module:
{moduleName}"
      IO.println ""
      IO.println s!"Name: 
{declName}"
      IO.println ""
      IO.println s!"Type: 
{declType}"
      IO.println ""
  else 
    throwError "Failed to fetch embedding." 

elab "#find_with_gpt" s:str : command => do
  let query := s.getString
  let gptRes ← GPTM.getResponse.run #[
    { role := .system 
      content := "You are an expert in mathematics and the Lean4 interactive proof assistant.
Your job is to take the user's input, written using plain LaTeX, and convert it to 
a Lean4 type expression.

Examples:

---

Input: 
For every natural number $n$, $n+1$ is positive.

Response:
∀ (n : ℕ), 0 < n + 1

---

Input:
If $G$ is a commutative group, and $a,b ∈ G$, the $a b = b a$.

Response: 
∀ (G : Type _) [CommGroup G] (a b : G), a * b = b * a
"},
  { role := .user, content := query }]
  let res ← EmbeddingM.getIndexedEmbeddings #[gptRes.content] |>.run 
  let res := res.map fun e => e.embedding
  if h : 0 < res.size then 
    let res := res[0]
    let query : Pinecone.Query := {
      topK := 10
      vector := res
      nmspace := "type"
    }
    let res ← PineconeM.query query |>.run
    let res := res.mtches.map fun m => (m.score, m.metadata)
    for r in res do
      let some metadata := r.2 | continue
      let .ok moduleName := metadata.getObjValAs? String "module" | continue
      let .ok declName := metadata.getObjValAs? String "name" | continue
      let .ok declType := metadata.getObjValAs? String "type" | continue
      let score := r.1
      IO.println "---"
      IO.println ""
      IO.println s!"Score:
{score}"
      IO.println ""
      IO.println s!"Module:
{moduleName}"
      IO.println ""
      IO.println s!"Name: 
{declName}"
      IO.println ""
      IO.println s!"Type: 
{declType}"
      IO.println ""
  else 
    throwError "Failed to fetch embedding." 