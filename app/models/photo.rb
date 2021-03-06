class Photo < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :photo_genre_maps, foreign_key: 'photo_id',
                              dependent: :destroy
  has_many :genres, through: :photo_genre_maps
  has_many :rates, dependent: :destroy

  mount_uploader :photo_image, PhotoUploader

  validates :photo_image, presence: { message: 'を選択してください' }
  validates :caption, length: { maximum: 250 }

  # =========== もういいねしてる? ============
  def favorited_by?(user)
    if user.nil?
      false
    else
      favorites.where(user_id: user.id).exists?
    end
  end

  # =============== ジャンル保存メソッド =================
  def save_photos(save_genres)
    current_genres = genres.pluck(:name) unless genres.nil?
    old_genres = current_genres - save_genres
    new_genres = save_genres - current_genres

    old_genres.each do |old_name|
      genres.delete Genre.find_by(name: old_name)
    end

    new_genres.each do |new_name|
      photo_genre = Genre.find_or_create_by(name: new_name)
      genres << photo_genre
    end
  end

  # ================ 写真検索用の記述 ==================
  def self.search(word)
    if word == ""
      Photo.all.order(id: "DESC")
    else
      name = Photo.where('caption LIKE?', "%#{word}%")
      genres = Photo.joins(:genres).where('genres.name LIKE?', "%#{word}%")
      name += genres
      photos = name.uniq
      photos.sort.reverse
    end
  end

  # ====================== 週間ランキング関連 ========================
  is_impressionable :counter_cache => true, :unique => true
  scope :this_week, ->    { where(created_at: 6.day.ago.beginning_of_day..Time.zone.now.end_of_day) }
  scope :this_month, ->   { where(created_at: 30.day.ago.beginning_of_day..Time.zone.now.end_of_day) }
  scope :impressions, ->  { where.not(impressions_count: 0) }
end
