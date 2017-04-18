post "/tftp/fetch_boot_file" do
  arr = nil
  reply_or_create_task(arr, 'post', 'TFTP Fetch Boot File ')
end

post "/tftp/:variant/create_default" do |variant|
end

get "/tftp/:variant/:mac" do |variant, mac|
end

post "/tftp/:variant/:mac" do |variant, mac|
end

delete "/tftp/:variant/:mac" do |variant, mac|
end

post "/tftp/create_default" do
  arr = nil
  reply_or_create_task(arr, 'post', 'TFTP Create Default')
end

post "/tftp/:mac" do |mac|
  arr = params[:mac]
  reply_or_create_task(arr, 'post', 'TFTP Post MAC')
end

delete "/tftp/:mac" do |mac|
  arr = params[:mac]
  reply_or_create_task(arr, 'delete', 'TFTP Delete MAC')
end

get "/tftp/serverName" do
  arr = nil
  reply_or_create_task(arr, 'get', 'TFTP Get Server Name')
end
