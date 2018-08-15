
class SLink

  attr_reader :data
  attr_accessor :next

  def initialize(data, m = nil)

    @data = data
    @next = m

  end
end

class Stack

  attr_accessor :head

  def initialize
    @head = nil
  end

  def push(data)

    if @head.nil?
      #kein element
      @head = SLink.new(data, nil)
      return self
    else
      ptr = @head
      @head = SLink.new(data, ptr)
    end

  end

  def empty?

    @head.nil?
  end

  def pop

    return nil if self.empty?
    ptr = @head
    @head = ptr.next
    ptr.data
  end

  def clear

    loop do

      self.pop
      break if self.empty?
    end
  end

end
