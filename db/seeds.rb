# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

user = User.find_or_initialize_by(email: 'lukas.svoboda@gmail.com')
user.encrypted_password = '$2a$10$ycxCXFaJ0pu9ZtxcjiIvl.7R9bKstMFlIo/wAw9BbsYt.4eApEIia'
user.confirmed_at = Time.now
user.save!

