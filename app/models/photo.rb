class Photo < ActiveRecord::Base
  has_attached_file :image
  belongs_to :business
  belongs_to :status_update

  has_attached_file :image, styles: {
                                        thumb: '100x100>',
                                        square: '200x200#',
                                        medium: '300x300>'
                                      }

  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  validates_attachment_size :image, :less_than => 5.megabytes

end
