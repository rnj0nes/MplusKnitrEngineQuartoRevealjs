-- default-code-lang.lua
-- Add 'text' language to code blocks that have no language
function CodeBlock(cb)
  if #cb.classes == 0 then
    cb.classes:insert('text')
  end
  return cb
end
