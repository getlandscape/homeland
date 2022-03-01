# ============ init Section, Node ================
%w[Fun Movie Music Apple Goolge Coding Activity Poll].each do |name|
  Node.find_or_create_by(name: name, summary: "...")
end

(1..100).each do |n|
  user = User.find_or_create_by(
    login: 'andy' + n.to_s,
    name: 'andy' + n.to_s,
    email: 'andy' + n.to_s + "@test.com",
    email_public: 'andy' + n.to_s + "@test.com",
    password: '111111',
    password_confirmation: '111111'
  )

  group = Group.find_or_create_by(
    name: 'Group' + n.to_s,
    description: 'Group' + n.to_s + 'description',
    group_type: 'public_group',
    status: 'approved'
  )

  GroupUser.find_or_create_by(
    user_id: user.id,
    group_id: group.id,
    role: :owner,
    status: :accepted
  )
end
