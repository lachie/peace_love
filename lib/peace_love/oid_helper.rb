module PeaceLove
  module OidHelper
    def oid(id)
      if BSON::ObjectId === id
        id
      else
        BSON::ObjectId(id)
      end
    end
  end
end
