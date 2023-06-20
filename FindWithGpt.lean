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