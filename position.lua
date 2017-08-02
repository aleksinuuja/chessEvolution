Position = {}

function Position:new(params)
  o = {}

  table.insert(o, {r_w, p_w, emp, emp, emp, emp, p_b, r_b})
  table.insert(o, {n_w, p_w, emp, emp, emp, emp, p_b, n_b})
  table.insert(o, {b_w, p_w, emp, emp, emp, emp, p_b, b_b})
  table.insert(o, {q_w, p_w, emp, emp, emp, emp, p_b, q_b})
  table.insert(o, {k_w, p_w, emp, emp, emp, emp, p_b, k_b})
  table.insert(o, {b_w, p_w, emp, emp, emp, emp, p_b, b_b})
  table.insert(o, {n_w, p_w, emp, emp, emp, emp, p_b, n_b})
  table.insert(o, {r_w, p_w, emp, emp, emp, emp, p_b, r_b})
  table.insert(o, "w") -- the pos[9] is whose turn it is, string "w" or "b"

  setmetatable(o, self)
  self.__index = self
  return o
end
