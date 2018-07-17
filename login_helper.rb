require 'fileutils'
require 'highline'
require 'bcrypt'

class Login
  #A simple class that handles basic login with encrypted storage
  #this oculd be used with a database to create a robust login system
  
  def self.add_user
    @login=Watcher.authenticate  #must be admin to add user
    if @login[0].is_admin==true

      cli = HighLine.new
      @flag=true
      @username=cli.ask("Name?  (last, first)  ") { |q| q.validate = /\A\w+, ?\w+\Z/ }
      @temp={}

      User.all.each do |user|
        if user.username.keys.include?(@username)
          print "User already in system!"
          @flag=false
        end
      end
      if @flag
        @temp[@username]=BCrypt::Password.create(cli.ask("Enter your password:  ") { |q| q.echo = "x" })
        @user=User.new
        @user.username=@temp
      end
    else
      print "this action requires admin permissions"
    end

  end

  def self.change_password

    @login=Watcher.authenticate #authenticates the user

    if @login[0]=true
      cli = HighLine.new
      user=@login[1]
      if user.username.keys.include?(@username) #lets then change their password
        if user.username[@username]==@password
          @input1=cli.ask("Enter your new password:  ") { |q| q.echo = "x" } #confirms if their passwords match
          @input2=cli.ask("Confirm your new password:  ") { |q| q.echo = "x" }
          if @input1 != @input2
            print "passwords did not match please try again"
            self.change_password
          else
            user.username[@username]=BCrypt::Password.create(@input1)
          end
          return "Password Changed!"
        end
      end
    end

  end

  def self.authenticate

    cli = HighLine.new

    @username=cli.ask("Name?  (last, first)  ") { |q| q.validate = /\A\w+, ?\w+\Z/ }  #ask for username and password
    @password=cli.ask("Enter your password:  ") { |q| q.echo = "x" }

    User.all.each do |user|
      if user.username.keys.include?(@username) #if username exists

        if user.locked==false && user.tries<4  #check the username and password combo if not locked or hasnt tried more than 4 times
          if user.username[@username]==@password #check if the entered password matches the encrypted version
            return true, user
          else
            print "Incorrect combination, please try again \n"
            user.tries+=1
            Watcher.authenticate
          end
        else
          user.locked=true
          print "That account is locked because of multiple login attempts \n"
          return false, nil
        end

      end
    end
    print "Incorrect combination, please try again \n"
    Watcher.authenticate


  end
end

class User
  attr_accessor :username,:is_admin,:tries,:locked


  def initialize(params = {})
    @is_admin = params.fetch(:is_admin, false)
    @tries = params.fetch(:tries, 0)
    @locked = params.fetch(:locked,false)
  end

  def self.all
    ObjectSpace.each_object(self).to_a
  end

end
