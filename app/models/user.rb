require 'active_resource'

class User < ActiveResource::Base
  extend ActiveModel::Naming
  self.site = Rails.configuration.account_ip

  def posts
    @posts ||= Post.where(user_id: id)
  end

  def id
    uid
  end

  def self.find(id)
    Rails.cache.fetch("users/#{id}.json") do
      user = super id
      user.positions = OpenStruct.new(user.positions.attributes).to_h
      user
    end
  end

  def committees
    @committees ||= Committee.all.select do |c|
      groups.include?(c.slug)
    end
  end

  def in_committee?
    committees.any?
  end

  def committees_include_any?(committee)
    !(committee & groups).empty?
  end

  def self.headers
    { 'authorization' => "Bearer #{Rails.application.secrets.client_credentials}"}
  end

end
