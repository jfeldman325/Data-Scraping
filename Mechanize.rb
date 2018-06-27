
class Browser
  require 'rubygems'
  require 'mechanize'
  require 'open-uri'
  require 'nokogirl'
  require 'net/http'
  require 'json'
  require 'news-api'
  require 'fileutils'
  require 'io/console'
  require 'highline'



  def self.like_tagged

    # this method accesses facebook and then likes any comment which tags you
    # outpus a summary of the post and comment that it liked for you

    @agent = Mechanize.new
    @agent.get('https://m.facebook.com/')
    @agent.follow_meta_refresh = true
    page= login_form = @agent.page.form_with(:method => 'POST')
    login_form.email = #username
    login_form.pass = #password

    page=@agent.submit(login_form, login_form.buttons.first)

    page=@agent.submit(page.forms.first, page.forms.first.buttons.first)

    print "login: "+(!@agent.page.uri.to_s.match('home.php').nil?).to_s+"\n"

    page = @agent.page.link_with(:text => 'Notifications').click

    # this line could be changed to access other content on facebook
    links=@agent.page.links_with(:text => "mentioned you in a comment")

    page.links.each do |link|


      if link.text.include? "mentioned you in a comment"
        @first_name=link.text.split(' ')[0]
        @last_name=link.text.split(' ')[1]

        page = link.click

        @agent.page.search("span.UFICommentBody").each do |comment|
          print comment.text
        end
        @i=0
        @x=0

        page.links.each do |link|
          if (/C-R/ ===link.uri.to_s)
            @pagename = link.text

          end

          if link.text.include? (@first_name+" "+@last_name)

            @x=@i
            while true do
              if (page.links[@x].text=="Like")

                if (/like_comment_id/ === page.links[@x].resolved_uri.to_s)

                    print "Match!: Liked comment from " + page.links[@i].text+" on "+@pagename+"\'s post\n"
                  page.links[@x].click
                end

              elsif (page.links[@x].text=="Reply")
                break
              else

              end
              @x=@x+1
            end


          end
          @i=@i+1
        end
        @i=0
      end
    end

    return nil

  end


  def self.find_relevant_articals
    #returns a formated list of news items with summary. The goal here is to
    # allow a user as part of an AI system add relevant news and get updats on some routine basis
    # could be used for a "smart mirror" application


    #these lists could be imputed as a parameter but are hard coded for the purpose of testing
    # You can either search for terms or for catagories availible in googles news api

    @relevant=["Elon Musk","Apple","Kanye West","Architecture","Virtual Reality"]
    @catagories=["business"]
    newsapi = News.new(#Your API KEY)
    @articals=[]
    @relevant.each do |rel|
      @top_headlines = newsapi.get_top_headlines(q: rel,pageSize: '5',language:'en')

      @top_headlines.each do |article|
        @articals<<article
      end
    end

    @catagories.each do |rel2|
      @top_headlines = newsapi.get_top_headlines(country:"us",category: rel2,pageSize: '10',)

      @top_headlines.each do |article|
        if !article.description.nil? && !article.author.nil? && !article.title.nil?
          @articals<<article
        end
      end
    end



    return @articals
  end

  def self.json_request(url)
    escaped_address=URI.escape(url)
    uri=URI.parse(escaped_address)
    json=JSON.parse(Net::HTTP.get(uri))
    return json
  end


  def self.scrape_timezone
    # this is a simple script to scrape a list of timezones from the url below
    # it writes the timezone information to a chosen text file
    @agent=Mechanize.new
    @page=@agent.get('https://timezonedb.com/time-zones')

    @page.search("tr")[1..-2].each do |x|
      @line=""
      x.search("td").each do |y|
        @line<< y.text+","
      end

      # print @line[0..@line.length-1]+"\n"
      File.write("YOUR TEXT FILE PATH",@line[0..@line.length-2]+"\n", File.size("YOUR TEXT FILE PATH"), mode: 'a')

    end

  end



  def self.common_words

    # this function has multiple implementations of web scraping to find a list of
    # comming adjectives for use in a database of world corrolations


    # @agent = Mechanize.new
    # @page=@agent.get('http://www.talkenglish.com/vocabulary/top-500-adjectives.aspx')
    # @page.search("tr").each do |x|
    #
    #   if x.search("a").text !=""
    #     Browser.synonyms(x.search("a").text,false)
    #   end
    # end
    #
    # return nil
    @agent = Mechanize.new
    @page=@agent.get('http://grammar.yourdictionary.com/parts-of-speech/adjectives/list-of-adjective-words.html')
    @words=@page.search("#article_main_content").search("ul")[0].text.split("\r\n")
    @words.each do |x|

      if x !=""
        # print x+"\n"
         Browser.synonyms(x,false)
      end


    end
    #
    # return nil
  #   @letters=["f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
  #   # @letters=["a"]
  #
  #   @letters.each do |letter|
  #     @agent = Mechanize.new
  #     @page=@agent.get("http://adjectivesstarting.com/with-#{letter}/")
  #     @agent.follow_meta_refresh = true
  #     @page.search(".word").each do |word|
  #       Browser.synonyms(word.text,true)
  #     end
  #   end
    return nil
  end


  def self.synonyms(word,flag)

    # Scrapes thesuarus.com and writes synonyms of the inputed word to a chosen File
    # the flag is used so that the method can either just find one itteration
    # or can fund synonyms of the synonyms (2nd order synonyms)

    @agent = Mechanize.new
    @flag=flag
    @page=@agent.get('http://www.thesaurus.com/browse/'+word)
    @agent.follow_meta_refresh = true
    @synonyms=@page.search(".css-1hn7aky")
    @syn_out=""

    @synonyms.each do |x|
      if @flag==false

        Browser.synonyms(x.text,true)
        @flag=false
      end
      @syn_out<<x.text+","

    end

    print word+"\n"

    self.Write("YOUR FILE PATH",word+":"+@syn_out.to_s[0..@syn_out.length-2].to_s+"\n",word)

  end

  def self.Write_synonyms(file,string,word)
    # helper method to append text to a file

    @flag=false
    File.open(file).each_line do |line|
      if (line =~ /^#{word}:/)
          # print "true"
          line=string
          @flag=true
          break
      end
    end
    # print @flag
    if @flag==false
      File.write(file, string, File.size(file), mode: 'a')
    end

  end

  def self.correct()

    # a helper method to correct the input from the output of the synonym generator
    @counter=0
    File.open("ORIGINAL FILE PATH").each_line do |line|
      if !(line =~ /^.+:$/)
        File.write("UPDATED FILE PATH", line, File.size("UPDATED FILE PATH"), mode: 'a')
        @counter+=1
      end
    end
    print @counter
  end
end
