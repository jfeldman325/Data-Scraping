require 'fileutils'

class Organize

  # Class takes any directory and completely organizes it within a folder called
  # "organized" allows you to select whether you want to organize by time
  # or organize by file type into file catagories. I used this to organize
  # my google drive and it handled over 5000 files within 6 seconds

  def self.check_path(path)

    # checks the path given to it and makes necessary adjustments
    # also allows to use common language such as "desktop" and "google drive"
    # so in the future as part of an AI natural langauge processor
    # it could organize things using pre defined paths

    @pre_def_paths={"desktop"=>"/Users/jacobfeldman/Desktop/","downloads"=>"/Users/jacobfeldman/Downloads/","google drive"=>"/Users/jacobfeldman/Google Drive/"}

    if !(path=~/\//)
      if !@pre_def_paths[path.downcase].nil?
        return @pre_def_paths[path.downcase]
      else
        return path+"/"
      end
    elsif !(path=~/\/$/)
      return path+"/"
    else
      return path
    end
  end

  def self.choose_loc(f,dir_from,dir_orig,cur_sub=nil)

    # takes a file and chooses in which sub folder it should go

    @blacklist=["images","3D",".","..","documents","music","photoshop","folders",".DS_Store","Organized","misc"]


    if !@blacklist.include?(f.to_s) && (f.to_s =~ /-pin/).nil?
      @days_ago=(Date.today-DateTime.parse(File.mtime(dir_from+f.to_s).to_s)).to_i

      @oldpath=dir_orig

      if @days_ago<=3
        @folder="Current/"

        if cur_sub.nil? || cur_sub!="Current"

          Organize.move_and_rename(@folder,dir_from,dir_orig,f.to_s)
        end
      elsif @days_ago >3 &&  @days_ago<31
        @folder="Last Month/"
        if cur_sub.nil? || cur_sub!="Last Month"
          Organize.move_and_rename(@folder,dir_from,dir_orig,f.to_s)
        end
      elsif @days_ago>=31 && @days_ago<90
        @folder="Last 3 Months/"

        if cur_sub.nil? || cur_sub!="Last 3 Months"
          Organize.move_and_rename(@folder,dir_from,dir_orig,f.to_s)
        end
      elsif @days_ago>=90 && @days_ago<365
        @folder="Last Year/"
        if cur_sub.nil? || cur_sub!="Last Year"
          Organize.move_and_rename(@folder,dir_from,dir_orig,f.to_s)
        end
      else
        if !File.exist?(@oldpath+"Organized/"+File.mtime(@oldpath+f.to_s).strftime("%Y"))
          FileUtils.mkdir(@oldpath+"Organized/"+File.mtime(@oldpath+f.to_s).strftime("%Y"))
        end

        Organize.move_and_rename(File.mtime(@oldpath+f.to_s).strftime("%Y")+"/",dir_from,dir_orig,f.to_s)
      end
    end
  end

  def self.by_time(dir,with_typesort)

    # this method initializes the processes for organizing a directory by time
    dir=Organize.check_path(dir)

    @files=Dir.entries(dir)

    if !File.exist?(dir+"Organized")
      FileUtils.mkdir(dir+"Organized")
      FileUtils.mkdir(dir+"Organized"+"/"+"Current")
      FileUtils.mkdir(dir+"Organized"+"/"+"Last Month")
      FileUtils.mkdir(dir+"Organized"+"/"+"Last 3 Months")
      FileUtils.mkdir(dir+"Organized"+"/"+"Last Year")

    end


    @files.each do |f|

      Organize.choose_loc(f,dir,dir)
    end

    if with_typesort

      Organize.by_type(dir+"Organized"+"/"+"Last Month/")
      Organize.by_type(dir+"Organized"+"/"+"Current/")
      Organize.by_type(dir+"Organized"+"/"+"Last Year/")
      Organize.by_type(dir+"Organized"+"/"+"Last 3 Months/")
    end

  end

  def self.by_type(dir)
    # initializes the organization of a directory by file type
    # this is called as a sub routine if you choose to sort by time and type

    dir=Organize.check_path(dir)
    @image_extensions=[".tif", ".tiff", ".gif", ".jpeg" ,".jpg" , ".jif", ".jfif", ".jp2", ".jpx", ".j2k", ".j2c", ".fpx", ".pcd", ".png"]
    @multiDfiles=[".obj",".ma",".mb",".stl",".fbx"]
    @documents=[".gdoc",".gsheet",".gslides",".pdf",".doc", ".docx", ".docm", ".dot", ".dotx", ".dotm", ".html", ".txt", ".rtf", ".odt",".ppt",".pptx",".zip",".xls","xlsx"]
    @music=[".WAV",".AIFF",".MP3",".ACC",".FLAC",".wav",".mp3",".aiff",".acc"]
    @photoshop=[".psd"]
    @blacklist=["images","3D",".","..","documents","music","photoshop","folders","misc"]

    @files=Dir.entries(dir)

    @files.each do |f|

      if !f.to_s.match(/(.+)(\.\w+)/).nil?
        @file_extension=f.to_s.match(/(.+)(\.\w+)/)[2]
        if @image_extensions.include?(@file_extension)
          if !File.exist?(dir+"images")
            FileUtils.mkdir(dir+"images")
          end
          FileUtils.mv(dir+f.to_s,dir+"images/"+f.to_s)
        elsif @multiDfiles.include?(@file_extension)
          if !File.exist?(dir+"3D")
            FileUtils.mkdir(dir+"3D")
          end
          FileUtils.mv(dir+f.to_s,dir+"3D/"+f.to_s)
        elsif @documents.include?(@file_extension)
          if !File.exist?(dir+"documents")
            FileUtils.mkdir(dir+"documents")
          end
          FileUtils.mv(dir+f.to_s,dir+"documents/"+f.to_s)
        elsif @music.include?(@file_extension)
          if !File.exist?(dir+"music")
            FileUtils.mkdir(dir+"music")
          end
          FileUtils.mv(dir+f.to_s,dir+"music/"+f.to_s)
        elsif @photoshop.include?(@file_extension)
          if !File.exist?(dir+"photoshop")
            FileUtils.mkdir(dir+"photoshop")
          end
          FileUtils.mv(dir+f.to_s,dir+"photoshop/"+f.to_s)
        else
          if !File.exist?(dir+"misc")
            FileUtils.mkdir(dir+"misc")
          end
          FileUtils.mv(dir+f.to_s,dir+"misc/"+f.to_s)
        end
      elsif !@blacklist.include?(f.to_s)
        if !File.exist?(dir+"folders")
          FileUtils.mkdir(dir+"folders")
        end
        FileUtils.mv(dir+f.to_s,dir+"folders/"+f.to_s)
      end
    end
    return nil
  end

  def self.move_and_rename(sub_folder,dir_from,dir_orig,filename)
    # moves and renames the file with a useful timestamp that tell you
    # when the last time was that you accessed the file
    # in practice the renaming should probably be more liberal but thats alright
    # for now

    # naming a file with -pin causes the file to stick in place and not be
    # moved or modified

    dir_from=Organize.check_path(dir_from)
    @newpath=dir_orig+"Organized/"+sub_folder


    if /(.+)-(.+\d\d-\d\d-\d\d\d\d)(\.\w+)$/ =~ filename.to_s
      @cleaned_name=Organize.clean_ext(filename)
      @name=@cleaned_name.to_s.match(/(.+)(\.\w+)/)[1]
      @file_extension=@cleaned_name.to_s.match(/(.+)(\.\w+)/)[2]
      @newname=@name+"-"+File.mtime(dir_from+filename).strftime("Edited last %A %m-%d-%Y")+@file_extension
    elsif !filename.to_s.match(/(.+)(\.\w+)$/).nil?
      @name=filename.to_s.match(/(.+)(\.\w+)/)[1]
      @file_extension=filename.to_s.match(/(.+)(\.\w+)/)[2]
      @newname=@name+"-"+File.mtime(dir_from+filename).strftime("Edited last %A %m-%d-%Y")+@file_extension
    else
      @newname=filename.to_s
    end

    File.rename(dir_from+filename.to_s,dir_from+@newname)

    FileUtils.mv(dir_from+@newname,@newpath+@newname)
  end

  def self.clean_ext(filename)
    # cleans the added extensions of files. Mostly used for updating
    if !filename.to_s.match(/(.+)-(.+\d\d-\d\d-\d\d\d\d)(\.\w+)$/).nil?
      @oldname=filename.to_s.match(/(.+)-(.+\d\d-\d\d-\d\d\d\d)(\.\w+)/)[1]+filename.match(/(.+)-(.+\d\d-\d\d-\d\d\d\d)(\.\w+)/)[3]

    end
    return @oldname
  end

  def self.update(dir,with_typesort)
    # updates the location in which files should be in based on the last time
    # they were accessed

    dir=Organize.check_path(dir)
    @type_names=["images","3D","documents","music","photoshop","folders","misc"]
    @time_names=["Last Month","Last 3 Months","Current","Last Year","2017","2016","2015"]
    if File.exist?(dir+"Organized")
      @time_names.each do |t|
        if File.exist?(dir+"Organized/"+t)
          @file_folders=Dir.entries(dir+"Organized/"+t)

          @file_folders.each do |f|
            if /(\.\w+)$/ =~ f.to_s
              Organize.choose_loc(f,dir+"Organized/#{t}/",dir,t)
            elsif @type_names.include?(f.to_s)
              @files=Dir.entries(dir+"Organized/#{t}/"+f.to_s)
              @files.each do |f2|
                Organize.choose_loc(f2,dir+"Organized/#{t}/"+f.to_s+"/",dir,"#{t}")
              end
            end
          end

        end
      end
    end

    if with_typesort
      Organize.by_type(dir+"Organized"+"/"+"Last Month/")
      Organize.by_type(dir+"Organized"+"/"+"Current/")
      Organize.by_type(dir+"Organized"+"/"+"Last Year/")
      Organize.by_type(dir+"Organized"+"/"+"Last 3 Months/")
    end
    print "Updated!"
  end

end
