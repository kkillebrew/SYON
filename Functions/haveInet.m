% Check the internet connection. Return 1 is connected 0 if not. 

function tf = haveInet()
  tf = false;
  try
    address = java.net.InetAddress.getByName('www.google.de');
    tf = true;
  end
end