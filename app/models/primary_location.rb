require 'csv'
class PrimaryLocation < ApplicationRecord
  has_and_belongs_to_many :instructors , dependent: :destroy
  has_one :user
  has_attached_file :logo, styles: { large: "400x400>", thumb: "80x80>" },  default_url: "https://s3.amazonaws.com/snowschoolers/cd-sillouhete.jpg",
        :storage => :s3,
        :bucket => 'snowschoolers'
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/


  def self.import(file)
    CSV.foreach(file.path, headers:true) do |row|
        location = PrimaryLocation.find_or_create_by(id: row['id'])
        location.update_attributes(row.to_hash)      
    end
  end

  def self.to_csv(options = {})
    desired_columns = %w{ id name partner_status calendar_status region state vertical_feet base_elevation peak_elevation skiable_acres average_snowfall lift_count address
    }
    CSV.generate(headers: true) do |csv|
      csv << desired_columns
      all.each do |location|
        csv << location.attributes.values_at(*desired_columns)
      end
    end
  end


end
