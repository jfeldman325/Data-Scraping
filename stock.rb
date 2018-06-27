require 'net/http'
require 'json'

module StockGrapher

  # This file contains a list of methods used to access API stock information
  # The module standardizes the information so that I could used it as part of
  # the Highline graphing gem in ruby. Planned to be used as part of a stock ticker

  def self.get_price_intraday(symbol,interval,value)

    # retreives the desired data for the past day of stock information.

    @values={"open"=>"1. open", "high"=>"2. high", "low"=>"3. low", "close"=>"4. close","volume"=> "5. volume"}
    json= json_request(build_uri({"function"=>"TIME_SERIES_INTRADAY","symbol"=>symbol,"interval"=>interval}))
    @output=make_standard(json,{:[] =>@values[value],:to_f=>nil},"Time Series (1min)")
    return @output
  end

  def self.get_Batch_price(symbols,value)
    # retrieves the current price of a list of sticks

    @values={"symbol"=>"1. symbol","price"=>"2. price", "volume"=>"3. volume"}

    @symbol_string=symbols.map { |i|  i.to_s }.join(",")
    json= json_request(build_uri({"function"=>"BATCH_STOCK_QUOTES","symbols"=>@symbol_string}))
    @output={}
    json["Stock Quotes"].each do |s|
      print s
      @output[s[@values["symbol"]]]=s[@values[value]].to_f
    end

    return @output

  end

  def self.build_uri (settings)
    # Designed to reduce repeat code and build the access uri for the alphavantage API
    @url="https://www.alphavantage.co/query?"
    settings.each do |fun,set|
      @url<<"#{fun}=#{set}&"
    end
    @url<<"apikey=71IHCL6YCZ0CX2UL"
    return @url
  end

  def self.json_request(url)
    # executes the json request
    escaped_address=URI.escape(url)
    uri=URI.parse(escaped_address)
    json=JSON.parse(Net::HTTP.get(uri))
    return json
  end

  def self.make_standard(json,fun,data_label)
    # takes the input data and standardizes it
    # uses the ruby .send syntax to execute necessary functions on the data
    # overal designed to reduce repeat code

    @output={}

    json[data_label].each do |key,value|

      if !value.nil?
        @val_fix=value
        fun.each do |function,fun_key|
          if fun_key!=nil
            @val_fix=@val_fix.send(function,fun_key)
          else
            @val_fix=@val_fix.send(function)
          end
          @val_fix
        end
        @output[key]=@val_fix
      end
    end
    return @output
  end

  def self.get_price_historical(interval,symbol,value, size)
    # retrieves historical day resolution data from any stock
    @values={"open"=>"1. open", "high"=>"2. high", "low"=>"3. low", "close"=>"4. close","volume"=> "5. volume"}
    @interval_hash={"monthly"=>"Monthly Time Series","daily"=>"Time Series (Daily)","weekly"=>"Weekly Time Series"}
    json= json_request(build_uri({"function"=>"TIME_SERIES_#{interval.upcase}","symbol"=>symbol,"outputsize"=>size}))

    @output=make_standard(json,{:[] =>@values[value],:to_f=>nil},@interval_hash[interval])
    return @output
  end

  def self.sector_performance(period)
    # returns graphable sectore performance data
    @period_hash={"current"=>"Rank A: Real-Time Performance","day"=>"Rank B: 1 Day Performance","5 day"=>"Rank C: 5 Day Performance","month"=>"Rank D: 1 Month Performance","3 month"=>"Rank E: 3 Month Performance","YTD"=>"Rank F: Year-to-Date (YTD) Performance","1 year"=>"Rank G: 1 Year Performance","3 year"=>"Rank H: 3 Year Performance","5 year"=>"Rank I: 5 Year Performance","10 year"=>"Rank J: 10 Year Performance"}
    @values={"open"=>"1. open", "high"=>"2. high", "low"=>"3. low", "close"=>"4. close","volume"=> "5. volume"}
    json= json_request(build_uri({"function"=>"Sector"}))
    @output={}
    json.each do |key,value|
      if key!="Meta Data"
        @fixed={}
        value.each do |i,j|
          @fixed[i]=j.match(/.+?(?=%)/)[0].to_f
        end

        @output[key]=@fixed
      end
    end
    return @output[@period_hash[period]]
  end

  def self.OBV
    # reads the OBV predictive statistic for each datapoint
    escaped_address = URI.escape('https://www.alphavantage.co/query?function=OBV&symbol=AAPL&interval=daily&apikey=71IHCL6YCZ0CX2UL')
    uri = URI.parse(escaped_address)
    json=JSON.parse(Net::HTTP.get(uri))
    @output={}
    json["Technical Analysis: OBV"].each do |key,value|
      @output[key]=(value["OBV"].to_f)/5000000
    end
    return @output

  end

  def self.HT_line(symbol,interval,value)
    # reads the HT model line 
    json= json_request(build_uri({"function"=>"HT_TRENDLINE","symbol"=>symbol,"interval"=>interval,"series_type"=>value}))
    @output=make_standard(json,{:[] =>"HT_TRENDLINE",:to_f=>nil},"Technical Analysis: HT_TRENDLINE")
    return @output
  end
end
