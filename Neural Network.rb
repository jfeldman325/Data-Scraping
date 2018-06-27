require 'awesome_print'
require 'colorized_string'
require 'colorize'

# this file generates a diamond or square search tree which can be
# traversed in any direction and randomly
# the idea is to create a drop out algorithm for nueral networks
# which takes a larger array of nodes and than developes sub paths
# which are trained for a sertain number of steps and then saved as part of
# a task

# overal looking to develope this into a way to train a single nueral net
# to analyze multiple functions

class Neuron
  attr_accessor :weight
  attr_accessor :bias
  attr_accessor :previous
  attr_accessor :trained
  attr_accessor :adj
  attr_accessor :next
  attr_accessor :id #[x,y] x=layer y=left to right number
end

class Network
  attr_accessor :inputs
  attr_accessor :outputs
  attr_accessor :layers
  attr_accessor :net
  attr_accessor :interconnect
  attr_accessor :branching_factor
  attr_accessor :total_nodes

  def build(n,connections,inputs,outputs,interconnect)
    random=Random.new
    @network={}
    @inputs=[]

    #############create the input layer#####################
    for i in 1..inputs do

      @n=Neuron.new
      @n.trained=false
      @n.adj=[]
      @n.id=[0,i]
      @n.weight=random.rand(-1..1)
      @n.bias=-1
      @n.previous=[]
      @n.next=[]
      @inputs<<@n
    end

    ########################################################

    ############create the branching layer##################
    @prev_layer=@inputs
    @layers=0
    @layer_node_count=0
    while ((inputs*(connections**(@layers)-1)/(Math::log(connections)))<=n/2)
      @layers+=1

      @layer_node_count=0
      @current_layer=[]
      @prev_layer.each do |node|
        for i in 1..connections do    ##generate neurons
          @n=Neuron.new
          @layer_node_count+=1
          @n.weight=(random.rand(-100..100).to_f)/100
          @n.trained=false
          @n.adj=[]
          @n.bias=-1
          @n.previous=[node]
          node.next<<@n
          @n.next=[]
          @n.id=[@layers,@layer_node_count]
          @current_layer<<@n
        end
      end
        #interconnect the neurons
        if (interconnect==true)

          for k in 0..@current_layer.length-1
            if k==0
              @current_layer[k].adj<<@current_layer[k+1]
            elsif k==@current_layer.length-1
              @current_layer[k].adj<<@current_layer[k-1]
            else
              @current_layer[k].adj<<@current_layer[k+1]
              @current_layer[k].adj<<@current_layer[k-1]
            end
            @current_layer[k].adj.each do |x|

            end

          end
        end

        @prev_layer=@current_layer

      end
    #######################################################

    ############Create the consolidation layers############
    for z in 0..@layers do
      @layers+=1
      # print @layer_node_count.to_s+"\n"
      @layer_node_count=0
      @current_layer=[]
      @num=0

      ##consolodate neurons at the rate of the branching factor until we risk
      #loosing outpus
      if !((@prev_layer.length/connections)<outputs)
        for a in 1..@prev_layer.length/connections do
          @n=Neuron.new
          @layer_node_count+=1
          @n.weight=(random.rand(-100..100).to_f)/100
          @n.trained=false
          @n.adj=[]
          @n.bias=-1
          @n.previous=[]
          @n.next=[]
          @n.id=[@layers,@layer_node_count]
          @current_layer<<@n
        end
      else
        for a in 1..outputs do
          @n=Neuron.new
          @layer_node_count+=1
          @n.weight=(random.rand(-100..100).to_f)/100
          @n.trained=false
          @n.adj=[]
          @n.bias=-1
          @n.previous=[]
          @n.next=[]
          @n.id=[@layers,@layer_node_count]
          @current_layer<<@n
        end
      end
      @assigned=0

      if !((@prev_layer.length/connections)<outputs)
        for b in 1..@prev_layer.length do

          if b%connections==0
            for u in 1..connections

              @current_layer[@assigned].previous<<@prev_layer[b-u]
              @prev_layer[b-u].next<<@current_layer[@assigned]
            end
            @assigned+=1
          end
        end
      elsif @prev_layer.length!=outputs


        for b in 1..@prev_layer.length do

          if b%connections==0
            for u in 1..connections

              @current_layer[@assigned].previous<<@prev_layer[b-u]
              @prev_layer[b-u].next<<@current_layer[@assigned]
            end
            @assigned+=1
          end

        end
        for c in @assigned..outputs
          for d in 1..connections
            @sample=@prev_layer.sample
            if !@current_layer[c-1].nil?
              @current_layer[c-1].previous<<@sample
              @counter=0
              @prev_layer.each do |node|
                if node.id==@sample.id
                  @found_index=@counter
                end
                @counter+=1
              end
              @prev_layer[@found_index].next<<@current_layer[c-1]
            end
          end
        end
      end

      if (interconnect==true)

        for k in 0..@current_layer.length-1
          if k==0
            @current_layer[k].adj<<@current_layer[k+1]
          elsif k==@current_layer.length-1
            @current_layer[k].adj<<@current_layer[k-1]
          else
            @current_layer[k].adj<<@current_layer[k+1]
            @current_layer[k].adj<<@current_layer[k-1]
          end

          @current_layer[k].adj.each do |x|
            if !x.nil?

            end
          end

        end
      end

      @prev_layer=@current_layer
    end
    #####################################################


    #assign the output
    self.net=@inputs
    self.layers=@layers+1
    self.inputs=inputs
    self.outputs=outputs
    self.interconnect=interconnect
    self.branching_factor=connections
    self.total_nodes=n

    return nil

  end


  def random_traverse(adj_ratio)
    random=Random.new

    @path=[]

    ###enable to test input/output and path###
    @current=self.net.sample
    # @output=@current.weight*@input
    # print @current.id
    ####
    @path<<@current.id
    while (!@current.nil? )

      @next_index=random.rand(1..adj_ratio)

      if @next_index==1 && !@current.id[0]==0

        @current=@current.adj.sample
      else
        @current=@current.next.sample
      end
      if (@current.nil?)
        break
      end
      @path<<@current.id

    end

    return @path
  end

  def create_sub_neural_cycle
    @paths=[]
    @inputs_found=[]
    @outputs_found=[]
    while @inputs_found.length<self.inputs || @outputs_found.length<self.outputs
      @paths<<self.random_traverse(2)

      @paths.each do |path|
        if !@inputs_found.include?(path[0])
          @inputs_found<<path[0]
        elsif !@outputs_found.include?(path[-1])
          @outputs_found<<path[-1]
        end
      end
    end


    @sorted=@paths.flatten(1).uniq.group_by{|i| i[0]}
    @flag=false
    @sorted.each do |x|
      @layer=x[1]
      @layer.each do |id|
        for x in 1..@paths.length

          if !@paths[x].nil?
            if @paths[x].include?(id) && @flag==false
              @y=x
              @flag=true
              if x>String.colors.length
                @y-=String.colors.length
              end
              print id.to_s.colorize(String.colors[@y])

            elsif @paths[x].include?(id) && @flag==true

              print "*x"

              break
            end

          end

        end
        @flag=false

      end
      print "\n"
    end

    return nil

  end

  ##########currently not working##########
  #########should implement a pp function########

  # def self.print_network(network)
  #
  #   @network=network[:data]
  #   @network.each do |node|
  #     print node.id
  #     print "\n"
  #   end
  #   @layer=@network[0].next[0]
  #   # print @layer
  #
  #   while @layer.next[0]!=nil
  #     @node=@layer
  #     @flag=false
  #     while !@node.nil? && (@node.adj!=nil && @node.adj!=[])
  #       print @node.id
  #
  #       if @node.adj.length==1 && @flag==false
  #         @flag=true
  #         @node=@node.adj[0]
  #       else
  #         @node=@node.adj[1]
  #       end
  #
  #     end
  #     print "\n"
  #     @layer=@layer.next[0]
  #
  #   end
  #   print @layer.id
  #
  # end
  #
  # def self.Build_and_print(n,connections,inputs,interconnect)
  #   @network=Network.build(n,connections,inputs,interconnect)
  #   Network.print_network(@network)
  #   return nil
  # end

end
