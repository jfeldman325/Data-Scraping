
class Imessage
  # takes an ichat file and outputs a plain text file of the conversation
  # later to be used to access data to train a natural language processor
  # to talk like me

  require 'fileutils'
  require 'io/console'

  def self.send_message(message,contact)
      # a small method I used to test the ability to send imessages through
      # a local rails server 
      %x(imessage --text \"#{message}\" --contacts #{contact})
  end

  def self.read_historical(file,name)
    @messages=[]
    @senderindex=[]
    @flag=false
    File.open(file).each_with_index do |line,index|


      if line=~ /<key>Sender<\/key>/
        @senderindex<<index

      end
    end


    File.open(file).each_with_index do |line,index|
        if line =~ /\s\s\s<string>(.+)<\/string>/
          if !(line =~/........-....-....-....-............/)

            File.write("/Users/jacobfeldman/Desktop/"+name+"_temp.txt", line.match(/\s\s\s<string>(.+)<\/string>/)[1]+"\n", File.size("/Users/jacobfeldman/Desktop/"+name+"_temp.txt"), mode: 'a')

          end
        end

        if @senderindex.include?(index-3)

          if line =~ /<integer>6<\/integer>/
            File.write("/Users/jacobfeldman/Desktop/"+name+"_temp.txt", "Jade: ", File.size("/Users/jacobfeldman/Desktop/"+name+"_temp.txt"), mode: 'a')

          else

            File.write("/Users/jacobfeldman/Desktop/"+name+"_temp.txt", "Jacob: ", File.size("/Users/jacobfeldman/Desktop/"+name+"_temp.txt"), mode: 'a')

          end
        end

      end

      File.open("/Users/jacobfeldman/Desktop/"+name+"_temp.txt").each_line do |line|
        if line=~/Jacob: / || line=~/Jade: /
          File.write("/Users/jacobfeldman/Desktop/"+name+"_out.txt", line, File.size("/Users/jacobfeldman/Desktop/"+name+"_out.txt"), mode: 'a')

        end
      end


    return nil
  end


end
