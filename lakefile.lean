import Lake
open Lake DSL

package «find_with_gpt» {
  -- add package configuration options here
}

require pinecone from git
  "https://github.com/adamtopaz/lean_pinecone.git"

require gpt from git
  "https://github.com/adamtopaz/lean_gpt.git"

require embeddings from git
  "https://github.com/adamtopaz/lean_embedding.git"

@[default_target]
lean_lib «FindWithGpt» {
  -- add library configuration options here
}
