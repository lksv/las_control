# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

user = User.find_or_initialize_by(email: 'lukas.svoboda@gmail.com')
user.password = user.password_confirmation = 'Urelevant password 123'
user.terms_of_service = '1'
user.confirmed_at = Time.now
user.role = 'admin'
user.save!
user.update_column(:encrypted_password, '$2a$10$ycxCXFaJ0pu9ZtxcjiIvl.7R9bKstMFlIo/wAw9BbsYt.4eApEIia')

official_notice_board_categories = [
  { name: 'Unknown', category_id: 1000 },
  { name: 'Dražební vyhlášky', category_id: 1001 },
  { name: 'Volná místa, výběrová řízení', category_id: 1002 },
  { name: 'Záměry, prodej a pronájem majetku města', category_id: 1003 },
  { name: 'Ztráty a nálezy', category_id: 1004 },
  { name: 'Koordinační harmonogramy výkopových prací', category_id: 1005 },
  { name: 'Dokumenty Krajského úřadu', category_id: 1006 },
]

official_notice_board_categories.each do |category|
  OfficialNoticeBoardCategory.find_or_create_by!(category)
end
