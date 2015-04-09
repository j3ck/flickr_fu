class Flickr::Photosets::Photoset
  attr_accessor :id,:num_photos,:title,:description,:primary_photo_id

  def initialize(flickr, attributes)
    @flickr = flickr
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end

  # Get the list of photos in a set.
  #
  # *calls*: {flickr.photosets.getPhotos}[https://www.flickr.com/services/api/flickr.photosets.getPhotos.html]
  #
  # == Options
  # * +:extras+ - (Optional) A comma-delimited list of extra information to fetch for each returned record.
  # * +:per_page+ - (Optional) Number of photos to return per page. If this argument is omitted, it defaults to 500. The maximum allowed value is 500.
  # * +:page+ - (Optional) The page of results to return. If this argument is omitted, it defaults to 1.
  # * +:privacy_filter+ - Return photos only matching a certain privacy level.
  #   * (1) public photos
  #   * (2) private photos visible to friends
  #   * (3) private photos visible to family
  #   * (4) private photos visible to friends & family
  #   * (5) completely private photos
  # * +:media+ (Optional) - Filter results by media type. Possible values are all (default), photos or videos
  # == Returns
  # An array of Flickr::Photoset::Photo
  def get_photos(options={})
    options = options.merge(:photoset_id=>id)
    rsp = @flickr.send_request('flickr.photosets.getPhotos', options)
    collect_photos(rsp)
  end

  # Add a photo to the end of an existing photoset.
  # *calls*: {flickr.photosets.addPhoto}[https://www.flickr.com/services/api/flickr.photosets.addPhoto.html]
  def add_photo(photo_id)
    rsp = @flickr.send_request('flickr.photosets.addPhoto', {:photo_id=>photo_id, :photoset_id => id})
  end

  protected
    def collect_photos(rsp)
      photos = []
      return photos unless rsp
      if rsp.photoset.photo
        rsp.photoset.photo.each do |photo|
          attributes = create_attributes(photo)
          photos << Flickr::Photos::Photo.new(@flickr,attributes)
        end
      end
      return photos
    end

    def create_attributes(photo)
      {:id => photo[:id],
       :secret => photo[:secret],
       :server => photo[:server],
       :farm => photo[:farm],
       :title => photo[:title]}
    end
end
