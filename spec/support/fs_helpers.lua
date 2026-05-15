local M = {}

function M.tmpdir()
  local path = os.tmpname()
  os.remove(path)
  os.execute('mkdir -p "' .. path .. '"')
  return path
end

function M.rmdir(path) os.execute('rm -rf "' .. path .. '"') end

function M.write_file(dir, rel, content)
  local full = dir .. "/" .. rel
  os.execute('mkdir -p "' .. full:match("(.*)/") .. '"')
  local f = io.open(full, "w")
  f:write(content or "")
  f:close()
end

function M.tmpfile(content)
  local path = os.tmpname()
  local f = assert(io.open(path, "w"))
  f:write(content)
  f:close()
  return path
end

function M.with_file(content, fn)
  local path = M.tmpfile(content)
  local ok, err = pcall(fn, path)
  os.remove(path)
  if not ok then
    error(err)
  end
end

return M
