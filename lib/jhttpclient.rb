require 'java'


class JHTTPClient
  java_import java.io.File
  java_import java.io.FileInputStream
  java_import java.security.KeyStore

  java_import org.apache.http.HttpEntity
  java_import org.apache.http.HttpResponse
  java_import org.apache.http.client.methods.HttpGet
  java_import org.apache.http.conn.scheme.Scheme
  java_import org.apache.http.conn.ssl.SSLSocketFactory
  java_import org.apache.http.impl.client.DefaultHttpClient
  java_import org.apache.http.util.EntityUtils


  def initialize(ts, password, url)
    @httpclient = DefaultHttpClient.new
    trustStore = KeyStore.getInstance(KeyStore.getDefaultType())
    instream = FileInputStream.new(File.new(ts))
    trustStore.load(instream, java.lang.String.new(password.to_s).toCharArray)
    socketFactory = SSLSocketFactory.new(trustStore)
    sch = Scheme.new("https", 443, socketFactory)
    @httpclient.getConnectionManager().getSchemeRegistry().register(sch)

    httpget = HttpGet.new(url)

    p httpget.getRequestLine()

    response = @httpclient.execute(httpget)
    entity = response.getEntity()

    p response.getStatusLine()
    p entity.getContentLength() if entity.nil?
    EntityUtils.consume(entity)

  end

  #def get(url, params)
  #  httpget = HttpGet.new(url)
  #end

end
