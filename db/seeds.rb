User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.name = "管理者 谷口"
  user.password = "111111"
  user.role = :admin
end

puts "初期ユーザーの作成が完了しました！"