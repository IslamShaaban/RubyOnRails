class User < ApplicationRecord

    #Relationship of User with Posts and Comments
    has_many  :posts, dependent: :destroy
    has_many  :comments, dependent: :destroy

    #Validation of Users
    validates :name, presence: true, uniqueness: {case_sensitive: false}
    validates :email, presence: true, uniqueness: {case_sensitive: false}, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
    validates :password, length: { minimum: 8}, :format => {:with => /^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$/,  multiline: true , message: "must be in Struct /^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$/ and at least 8 characters includes one number and one letter ."}
    
    #Password Encryption
    has_secure_password

    #Relationship of User and Image
    has_one_attached :image
   
    #Check Password is Valid or Not
    def valid_password(password, hash)
        BCrypt::Password.new(hash) == password
    end
end