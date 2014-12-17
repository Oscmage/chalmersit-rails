class Post < ActiveRecord::Base
  scope :ordered, -> { order(created_at: :desc) }

  has_many :comments, dependent: :destroy

  translates :title, :body, :slug
  globalize_accessors

  validates *globalize_attribute_names, :title, :body, :user_id, :group_id, presence: true
  validates *(globalize_attribute_names.select{|a| a.to_s.include?("title")}), length: { in: 5..50 }
  validates *(globalize_attribute_names.select{|a| a.to_s.include?("body")}), length: { in: 10..5000 }
  validates :sticky, inclusion: { in: [true, false] }
  validates :slug, uniqueness: { case_sensitive: true }, presence: true, if: 'title.present?'

  before_validation :generate_slug

  def previous
    Post.where('id < ?', id).order(id: :desc).first
  end

  def next
    Post.where('id > ?', id).first
  end

  def to_param
    "#{id}-#{slug}"
  end

  def generate_slug
    I18n.available_locales.each do |locale|
      # Set slug to each locale if not already set.
      Globalize.with_locale locale do
        self.slug ||= title.try(&:parameterize)
      end
    end
  end
end
