module JTOpenCourse

  require 'erb'
  require 'date'

  VERSION = "0.0.4-alpha"

  SPELLED_NUMS = %w(
    Zero One Two Three Four Five Six Seven Eight Nine Ten Eleven Twelve Thirteen Fourteen Fifteen
    Sixteen Seventeen Eighteen Nineteen Twenty Twenty-One Twenty-Two Twenty-Three Twenty-Four
    Twenty-Five
  )

  # No small amount of this code has been either inspired or just about lifted from Jekyll's
  # ThemeBuilder class at https://github.com/jekyll/jekyll/blob/master/lib/jekyll/theme_builder.rb

  class SiteBuilder
    SCAFFOLD_DIRECTORIES = %w(
      _data policies projects syllabus/_policies syllabus/_projects syllabus/_weeks
    ).freeze

    attr_reader :name, :path, :anchor_date, :week_count, :project_count

    def initialize(course_name)
      @name = course_name.chomp
      @anchor_date = Date.parse("2020-01-13")
      @week_count = 5
      @project_count = 3
      @path = Pathname.new(File.expand_path(name, Dir.pwd))
    end

    def create!
      create_directories
      create_config_yml
      create_calendar_data
      create_projects
      create_weeks
    end

    def starter_path
      @starter_path ||= Pathname.new(File.expand_path("starter_files", __dir__))
    end

    def create_directories
      mkdir_p(SCAFFOLD_DIRECTORIES)
    end

    def create_template_data
    end

    def create_projects
      pc = @project_count
      while @project_count > 0
        write_file("syllabus/_projects/project-#{@project_count.to_s.rjust(2,"0")}.md",process_template("syllabus/_projects/project-00.md"))
        @project_count -= 1
      end
      @project_count = pc
    end

    def create_weeks
      wc = @week_count
      while @week_count > 0
        write_file("syllabus/_weeks/week-#{@week_count.to_s.rjust(2,"0")}.md",process_template("syllabus/_weeks/week-00.md"))
        @week_count -= 1
      end
      @week_count = wc
    end

    def create_config_yml
      write_file("_config.yml",process_template("_config.yml"))
    end

    def create_calendar_data
      write_file("_data/calendar.yml",process_template("_data/calendar.yml"))
    end

    def mkdir_p(directories)
      Array(directories).each do |d|
        FileUtils.mkdir_p(path.join(d))
      end
    end

    def render_erb(contents)
      ERB.new(contents).result binding
    end

    def process_template(filename)
      render_erb(find_template_file(filename).read)
    end

    def find_template_file(filename)
      [
        starter_path.join("#{filename}.erb"),
        starter_path.join(filename.to_s)
      ].find(&:exist?)
    end

    def write_file(filename, contents)
      full_path = path.join(filename)
      File.write(full_path, contents)
    end

  end

end
