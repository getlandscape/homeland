# ============ init Section, Node ================
%w[Fun Movie Music Apple Goolge Coding Activity Poll].each do |name|
  Node.find_or_create_by(name: name, summary: "...")
end
