class Book < ApplicationRecord
  belongs_to :category

  # Chronological Hijri month names (must match how `reading_month` is stored).
  HIJRI_MONTH_ORDER = %w[
    محرم صفر ربيع\ الأول ربيع\ الثاني
    جمادى\ الأولى جمادى\ الآخرة رجب شعبان
    رمضان شوال ذو\ القعدة ذي\ الحجة
  ].freeze
end
