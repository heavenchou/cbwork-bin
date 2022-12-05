class P5Node
  CB = %w[def dialog div docNumber event fan jhead jl_byline jl_juan jl_title juan mulu sg t tt yin zi]
  EMPTY = %w[anchor caesura lb milestone mulu pb space]

  attr_accessor :attributes, :content, :tag

  def initialize(e, args={})
    if e.nil?
      @tag = ''
      @attributes = {}
    else
      @tag = e.name
      @attributes = e.attributes
    end

    @resp_id = args[:resp_id]
    @p5b_format = args[:p5b_format]
    @wit_id = args[:wit_id]
  end

  def []=(key, value)
    @attributes[key] = value
  end

  def [](key)
    @attributes[key].to_s
  end

  def delete(key)
    @attributes.delete(key)
  end

  def key?(key)
    @attributes.key?(key)
  end

  def open_tag
    # 要歸入 cbeta namespace 的元素
    @tag = "cb:#{@tag}" if CB.include?(@tag)
      
    r = "<#{@tag}"

    @attributes.each do |k, v|
      k2 = add_namespace(k)

      v2 = v.to_s.gsub('&', '&amp;')
      v2.gsub!('<', '&lt;')
      v2 = case k  
      when 'resp', 'cb:resp'
        handle_resp(v2)
      when 'wit'
        handle_wit(v2)
      else
        v2
      end

      r += %( #{k2}="#{v2}")
    end

    r += '/' if EMPTY.include?(@tag)
    r += '>'
    return r
  end

  def end_tag
    return '' if EMPTY.include?(@tag)
    "</#{@tag}>"
  end

  def to_s
    open_tag + @content + end_tag
  end
    
  private

  def add_namespace(k)
    return k if k.include?(':') # 已有 namespace
    r = k
    case k
    when 'behaviour'
      r = "cb:#{k}" if %w[term text].include?(@tag)
    when 'cert'
      r = "cb:#{k}" if @tag == 'foreign'
    when 'id', 'lang'
      r = "xml:#{k}"
    when 'note_key'
      r = 'cb:note_key' if @tag == 'note'
    when 'place'
      r = 'cb:place' if %w[entry foreign lg].include?(@tag)
    when 'provider'
      r = 'cb:provider' if %w[note lem rdg].include?(@tag)
    when 'resp'
      r = 'cb:resp' if %w[choice foreign].include?(@tag)
    when 'type'
      r = 'cb:type' if %w[byline choice p sp].include?(@tag)
    when 'word-count'
      r = "cb:#{k}" if @tag != 'cb:tt'
    else
      k
    end
    r
  end

  def handle_resp(resp)
    return '' if resp.nil?

    # 將 resp="【甲】【乙】" 這一類的格式插入空格, 【甲】與【乙】才能分離出來 --2013/07/29
    resp2 = resp.gsub('】【', '】 【')

    # P5b 不用轉成 #resp 代碼, 直接傳回
    return resp2 if @p5b_format

    resps = []
    resp2.split.each do |r|
      unless @resp_id.key?(r)
        abort "Error resp 屬性 #{r} 沒有對應的 ID, #{__FILE__}, #{__LINE__}" 
      end
      resps << "##{@resp_id[r]}"
    end

    resps.join(' ')
  end

  def handle_wit(wit)
    return '' if wit.nil?

    # P5b 不用轉成 #wit 代碼, 直接傳回
    return wit.gsub('】【', '】 【') if @p5b_format

    wits = wit.scan(/【.*?】/)
    abort "error #{__LINE__}" if wits.empty?

    r = []
    wits.each do |w|
      # 不應該發生
      abort "error #{__LINE__} wit no id." unless @wit_id.include?(w)
        
      r << "##{@wit_id[w]}"
    end
    
    r.join(' ')
  end

end