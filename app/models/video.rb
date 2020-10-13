class Video < ApplicationRecord
    belongs_to :user
    has_one_attached :clip
    has_one_attached :thumbnail

    def as_json(options = {})
        super(options.merge(include: :user))
    end

end



