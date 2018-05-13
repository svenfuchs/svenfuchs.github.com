class Posts::Archive < Minimal::Template
  def to_html
    div :id => :page do
      div :id => :content do
        p capture { link_to('&larr; Home'.html_safe, '/') }
        h1 'Archive'
        archive
      end
    end
  end

  def archive
    ul :id => :archive do
      archived_posts.each do |year, posts|
        li do
          self.year(year, posts)
        end
      end
    end
  end

  def year(year, posts)
    h2 year
    ul do
      posts.each do |month, posts|
        li do
          self.month(month, posts)
        end
      end
    end
  end

  def month(month, posts)
    h3 month
    ul do
      posts.each do |post|
        li capture { link_to(post.title, [post.section, post]) }
      end
    end
  end

  def archived_posts
    Blog.first.posts.group_by { |post| post.published_at.year }.tap do |archive|
      archive.each do |year, posts|
        archive[year] = posts.group_by do |post|
          I18n.l(post.created_at, :format => '%B')
        end
      end
    end
  end
 end
