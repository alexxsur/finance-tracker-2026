class User < ApplicationRecord
  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :friendships
  has_many :friends, through: :friendships, source: :friend

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def stock_already_tracked?(ticker_symbol)
    stock = Stock.check_db(ticker_symbol)
    stock.present? && stocks.where(id: stock.id).exists?
  end

  def under_stock_limit?
    stocks.count < 10
  end

  def can_track_stock?(ticker_symbol)
    under_stock_limit? && !stock_already_tracked?(ticker_symbol)
  end

  def full_name
    [ first_name, last_name ].select(&:present?).join(" ").presence || "Anonymous"
  end

  def self.search(parameter)
    query = parameter.to_s.strip
    return [] if query.blank?

    (first_name_matches(query) + last_name_matches(query) + email_matches(query)).uniq
  end

  def self.first_name_matches(parameter)
    matches(:first_name, parameter)
  end

  def self.last_name_matches(parameter)
    matches(:last_name, parameter)
  end

  def self.email_matches(parameter)
    matches(:email, parameter)
  end

  def self.matches(field_name, parameter)
    field = field_name.to_s
    unless %w[first_name last_name email].include?(field)
      raise ArgumentError, "Unsupported user search field: #{field_name}"
    end

    query = parameter.to_s.strip
    return [] if query.blank?

    escaped_query = sanitize_sql_like(query.downcase)
    where("LOWER(#{field}) LIKE ?", "%#{escaped_query}%").to_a
  end
end
