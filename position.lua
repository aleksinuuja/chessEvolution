Position = {}

function Position:new(params)
  o = {}

  table.insert(o, {r_b, p_b, emp, emp, emp, emp, p_w, r_w})
  table.insert(o, {n_b, p_b, emp, emp, emp, emp, p_w, n_w})
  table.insert(o, {b_b, p_b, emp, emp, emp, emp, p_w, b_w})
  table.insert(o, {q_b, p_b, emp, emp, emp, emp, p_w, q_w})
  table.insert(o, {k_b, p_b, emp, emp, emp, emp, p_w, k_w})
  table.insert(o, {b_b, p_b, emp, emp, emp, emp, p_w, b_w})
  table.insert(o, {n_b, p_b, emp, emp, emp, emp, p_w, n_w})
  table.insert(o, {r_b, p_b, emp, emp, emp, emp, p_w, r_w})
  table.insert(o, "w") -- the pos[9] is whose turn it is, string "w" or "b"

  setmetatable(o, self)
  self.__index = self
  return o
end
