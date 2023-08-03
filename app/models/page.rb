class Page < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  belongs_to :parent, class_name: 'Page'
  has_many :childrens, class_name: 'Page', foreign_key: 'parent_id'
  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9_а-яА-Я]+\z/ }
  validates :header, presence: true
  before_save :edit_page
  before_update :edit_page
  
  # Функция для преобразования параметров страницы
  def edit_page
    # Русское название переводим в транслит
    self.name = normalize_friendly_id(self.name)
    # Преобразование в жирный шрифт
    self.description.scan(/\*.+\*/).each do |b|
      self.description.gsub!(b, "<b>" + b[1..-2] + "</b>")
    end
    # Преобразование в курсив
    self.description.scan(/\\.+\\/).each do |i|
      self.description.gsub!(i, "<i>" + i[1..-2] + "</i>")
    end
    self.description.gsub!("\\", "")
    # Преобразование в ссылку
    self.description.scan(/\(\([a-zA-Z0-9_а-яА-Я\/]+ .+\)\)/).each do |a|
      path, str = a[2..-3].split(" ")
      self.description.gsub!(a, "<a href='http://0.0.0.0:3000/#{path}'>#{str}</a>")
    end
  end

  # Обратное преобразование текста для редактирования пользователем
  def unreplace_description
    return "" unless self.description
    # Преобразование из жирного шрифта и курсива
    description = self.description.gsub(/<b>|<\/b>/, "*").gsub(/<i>|<\/i>/, "\\")
    # Преобразование из ссылки
    description.scan(/<a href='.+'>.+<\/a>/).each do |a|
      link = a.match(/<a href='http:\/\/0.0.0.0:3000\/(.+)'>(.+)<\/a>/)
      description.gsub!(a, "((" + link[1..2].join(" ") + "))" ) if link
    end
    description
  end

  def normalize_friendly_id(text)
    text.to_slug.transliterate(:russian).normalize.to_s
  end
end
