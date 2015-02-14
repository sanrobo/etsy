#Chapter-2
rails new etsy
rails generate controller Pages about contact

#app dizinini komple sublime text içinde açmak
subl .

#scaffold ürettiğimiz için İlk harf büyük, sonra migrate yaptık
rails generate scaffold Listing name:string description:text price:decimal
rake db:migrate

#root sayfası belirleme app/config/routes.rb 
root 'listings#index'

#bootstrap yükle, ardından bundle install
#gem 'bootstrap-sass', '~> 3.3.3'
#assets/stylesheets/custom.css.scss ve assets/javascripts/applications.js editlenecek

#partial yaratma
#partiallar _ ile başlar "_header.html.erb" gibi
<%=render 'layouts/header'%>

#sisteme imagemagick yükle, gemfile'e paperclip, migration image alanını ilave etmek için
$ rails generate paperclip listing image
# model dosyasına image alanını ekle, controller strong parametreyi güncelle, forma ekstra alan ekle ve formu güncelle
<%= form_for @listing, :url => users_path, :html => { :multipart => true } do |form| %>
  <%= form.file_field :image %>
<% end %>

#resimleri gösterme
<%= image_tag listing.image.url(:thumb) if listing.image %> 
#bootstrap grid eklendi 
#css manipulation için scaffold.scss silinmeli custom.scss içinde düzenleme yapılmalı

#bootstrap yerleşim problemini çözmek için custom.scss.css içinde
.col-md-4:nth-child(3n+1){
	clear:left;
}

#Git 
git init
git remote add origin https://github.com/ysantur/etsy.git
git status
git add .
git commit -m "comment"
git push -u origin master

#heroku fedora kurulumu, ardından heroku'yu path'e eklemek lazım
wget -qO- https://toolbelt.heroku.com/install.sh | sh

#postgresql kurulumu
sudo yum install postgresql
sudo yum install postgresql-devel
gem install pg

#heroku deploy
heroku create
heroku rename yeni-isim
git status
git add .
git commit -m "heroku deploy"
git push heroku master
heroku run rake db:migrate
heroku open #tarayıcıda görüntülemek için

#dropbox settings, paperclip-dropbox settings
gem 'paperclip-dropbox', '~> 1.3.1'
#depolanmasını istediğimiz modelde has_attached_file virgülden sonra aşağısı eklenir
    :storage => :dropbox,
    :dropbox_credentials => Rails.root.join("config/dropbox.yml"),
#config/dropbox.yml dosyası yaratılır içeriği paperclip-dropbox documantatioun da var
	app_key: "..."
	app_secret: "..."
	access_token: "..."
	access_token_secret: "..."
	user_id: "..."
	access_type: "dropbox|app_folder"
#https://www.dropbox.com/developers/apps/create, bu adresten dropbox.yml içeriği oluşacak
rake dropbox:authorize APP_KEY=uga855ttwf0zyov APP_SECRET=oe12k256b3c2d8n ACCESS_TYPE=app_folder
#adımları takiben access token/secret, user_id verilecek bunları tekrar güncellicez

#figaro gem
gem 'figaro'
figaro install # rails ön eki olmadan
#config/application.yml dosyasına dropbox.yml'de ki iki satırı kopyala ve büyük harfle değiştir
	APP_SECRET: "oe12k256b3c2d8n"
	ACCESS_TOKEN_SECRET: "0ndhleknkrmp3tj"
#büyük harfle değiştirdiğimiz için dropbox.yml'de ki açık verileri aşağıdaki gibi değiştir
	app_secret: <%=ENV["APP_SECRET"] %>
	access_token_secret: <%=ENV["ACCESS_TOKEN_SECRET"] %>

#figaro heroku entegrasyonu
figaro heroku:set
#git, github, heroku ya push et, heroku'da hata verecek, heroku log'larını görüntülemek için
heroku logs

#development ortamı ise localhosttakiler public klasöründe değilse dropboxa kaydedilsin modelde ki güncellemeler aşağıdaki gibi
	  if Rails.env.development?
	  	has_attached_file :image, :styles => { :medium => "200x200>", :thumb => "100x100>" }, :default_url => "missing.png"
	  else
	  	has_attached_file :image, :styles => { :medium => "200x200>", :thumb => "100x100>" }, :default_url => "missing.png",
	    :storage => :dropbox,
	    :dropbox_credentials => Rails.root.join("config/dropbox.yml"),
	    :path => ":style/:id_filename"
	    validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
	  end 

#Kullanıcı yönetimi için devise kurulumu
gem 'devise' #Mutlaka versiyonu yaz rails 4.2.0 da bug var!
rails generate devise:install
#Mail ayarları için config/environments/development.rb içinde
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
#Hata mesajlarını görüntülemek için application.html.erb içinde
	<p class="notice"> <%=notice%> </p>
	<p class="alert"> <%=alert%> </p>
#Devise kurulum ve yapılandırma
rails generate devise:views
rails generate devise User
rake db:migrate

#link_to helper ve Çıkış linki eklemek
<%=link_to "Sign Out",destroy_user_session_path,method: :delete%>

#Conditional linkler eklemek, header.html.erb içine
<%if user_signed_in?%>
#Kullanıcı kim
current_user.name

#Devise için helper oluşturma,app/helper/devise_helper.rb => dosya içine yazılır

#Devise tablosuna isim ve soyisim eklemek
rails generate migration AddNameToUsers name:string
rails generate migration AddSurnameToUsers surname:string
rake db:migrate
#app/controllers/concerns/application_controller.rb dosyasına strong parametreler ekliyoruz
	  before_action :configure_permitted_parameters, if: :devise_controller?
	  protected
	  def configure_permitted_parameters
	    devise_parameter_sanitizer.for(:sign_up) << :name
	    devise_parameter_sanitizer.for(:account_update) << :name
	    devise_parameter_sanitizer.for(:sign_up) << :surname
	    devise_parameter_sanitizer.for(:account_update) << :surname
	  end
#Views değişiklikleri, views/devise/registrations/*.erb içine name,surname alanları ilave ediyoruz

#Devise ayarları 
	app/config/initializers/devise.rb 

#Validates Syntax
validates :alan(lar), options: {value}

#########################################################################################
#LISTING İLE USER İKİŞKİSİ KURMA
rails generate migration AddUserIdToListing user_id:integer
rake db:migrate
#app/models/listing.rb
 belongs_to :user
#app/models/user.rb
 has_many :listings, dependent: :destroy  #s çoğul ifadesine dikkat
 #app/controller/listings_controller.rb create methodu içinde listing user'ını belirt
     @listing.user_id=current_user.id
     #listing.user.name şeklinde erişim yapılabilir
#Kullanıcı denetimi app/controllers/listing_controller içinde
  before_filter :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_filter :check_user, only: [:edit, :update, :destroy] 
  #Yukarıdaki :check_user 'a binaen şu methodu en aşağıya ilave et
    def check_user
      if current_user!=@listing.user
        redirect_to root_url, alert: "Geçerli kullanıcı değilsiniz"
      end
    end
 #Son olarak View içinde if ile link denetimi yapmak
 	<% if(user_signed_in?) && (current_user==listing.user)%>
#Resme link vermek
      <%= image_tag listing.image.url(:thumb) %>
      <%=link_to image_tag(listing.image.url(:thumb)),listing%>


#####################################################################
#SELLER PAGE OLUŞTURMA
#Yeni bir route oluşturmak
	get 'seller' => 'listings#seller'
#app/controller/listing_controller içinde seller methodu oluştur
  def seller
    @listings=Listing.where(user: current_user).order("created_at DESC")
  end #before_filter seçeneklerine bu methodu eklemeyi unutma sonra view'ını oluştur

########################################################################
#ORDER Oluşturma
rails generate scaffold Order address:string city:string state:string
rails generate migration AddListingIdToOrders listing_id:integer

rake db:migrate

#app/model/listing.rb içinde ilişki tanımla
  has_many :orders
#app/model/order.rb içinde ilişki tanımla
 belongs_to :listing
#app/model/order.rb içinde ilişki
	belongs_to :buyer, class_name: "User"
	belongs_to :seller, class_name: "User"
#app/model/user.rb içinde ilişki tanımla
  has_many :sales, class_name: "Order",foreign_key: "seller_id"
  has_many :purchases, class_name: "Order", foreign_key: "buyer_id"

rails generate migration AddFieldsToOrders buyer_id:integer seller_id:integer
#app/controller/order_controller.rb içinde kullanıcı authenticate_user! tanımla ve buyer_id, seller_id tanımla
    @order.buyer_id=current_user.id #create methodu içinde
#routes.rb içinde listings/id/order/new şeklinde sipariş için değişiklik
  resources :listings do
    resources :orders
  end
 #order_controller içinde seller_id çekmemiz için listing parametresi lazım
 	@listing=Listing.find(params[:listing_id]) #create ve new içine eklenmesi lazım
    @seller=@listing.user   
    @order.listing_id=@listing.id
    @order.seller_id=@seller.id #form save'den sonra redirect root_url olarak değiştir

#app/views/orders/new içinde link düzenlenmesi gerekiyor
	<%= link_to 'Back', listing_orders_path %>
#app/views/orders/_form.html.erb içinde form değişmeli (nested resources var çünkü)
	<%= form_for([@listing,@order]) do |f| %>
#app/views/listings/show içinde listinglere Buy It eklemek
	<%= link_to 'Buy It', new_listing_order_path(@listing),class:"btn btn-primary" %>
