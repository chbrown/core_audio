module AudioToolbox
  attach_function :AUGraphAddNode, [:pointer, :pointer, :pointer], :int
  attach_function :AUGraphConnectNodeInput, [:pointer, :int32, :uint32, :int32, :uint32], :int
  attach_function :AUGraphGetIndNode, [:pointer, :uint32, :pointer], :int
  attach_function :AUGraphInitialize, [:pointer], :int
  attach_function :AUGraphNodeInfo, [:pointer, :int32, :pointer, :pointer], :int
  attach_function :AUGraphOpen, [:pointer], :int
  attach_function :AUGraphClose, [:pointer], :int
  attach_function :AUGraphStart, [:pointer], :int
  attach_function :AUGraphStop, [:pointer], :int
  attach_function :AUGraphUpdate, [:pointer, :pointer], :int
  attach_function :CAShow, [:pointer], :void
  attach_function :DisposeAUGraph, [:pointer], :int
  attach_function :NewAUGraph, [:pointer], :int
  
  MAC_ERRORS[-10860] = "Node not found"
  MAC_ERRORS[-10861] = "Invalid connection"
  MAC_ERRORS[-10862] = "Output node error"
  MAC_ERRORS[-10863] = "Cannot do in current context"
  MAC_ERRORS[-10864] = "Invalid AudioUnit"
  
  class AUGraph
    def initialize
      graph_ptr = FFI::MemoryPointer.new(:pointer)
      require_noerr("NewAUGraph") {
        AudioToolbox.NewAUGraph(graph_ptr)
      }
      @graph = graph_ptr.read_pointer
      @nodes = {}
    end
    
    attr_reader :graph #:nodoc:
    
    def dispose
      require_noerr("DisposeAUGraph") {
        AudioToolbox.DisposeAUGraph(@graph)
      }
      @disposed = true
      return nil
    end
    
    def open 
      require_noerr("AUGraphOpen") {
        AudioToolbox.AUGraphOpen(@graph)
      }
      return self
    end
    
    def close
      require_noerr("AUGraphClose") {
        AudioToolbox.AUGraphClose(@graph)
      }
      return self
    end
    
    def update
      require_noerr("AUGraphUpdate") {
        AudioToolbox.AUGraphUpdate(@graph, nil)
      }
      return self      
    end
    
    def init
      require_noerr("AUGraphInitialize") {
        AudioToolbox.AUGraphInitialize(@graph)
      }
    end
    
    def start
      require_noerr("AUGraphStart") {
        AudioToolbox.AUGraphStart(@graph)
      }
    end
    
    def stop
      require_noerr("AUGraphStop") {
        AudioToolbox.AUGraphStop(@graph)
      }
    end
    
    def add_node(component_description)
      if component_description.kind_of?(Hash)
        component_description = ComponentManager::ComponentDescription.from_hash(component_description)
      end
      node_ptr = FFI::MemoryPointer.new(:pointer)
      require_noerr("AUGraphAddNode") {
        AudioToolbox.AUGraphAddNode(@graph, component_description, node_ptr)
      }
      return self
    end
    
    def connect_node_input(outnode, output, innode, input)
      require_noerr("AUGraphConnectNodeInput") {
        AudioToolbox.AUGraphConnectNodeInput(@graph, outnode.to_i, output, innode.to_i, input)
      }
    end
    
    def show
      AudioToolbox.CAShow(@graph)
    end
    
    def node_at(index)
      node_ptr = FFI::MemoryPointer.new(:uint32)
      require_noerr("AUGraphGetIndNode") {
        AudioToolbox.AUGraphGetIndNode(@graph, index, node_ptr)
      }
      int = node_ptr.read_int
      @nodes[int] ||= AUNode.new(self, int)
      @nodes[int]
    end
  end
  
  class AUNode
    # AUNodes are created by calling AUGraph#add_node.
    def initialize(graph, node)
      @graph = graph
      @node  = node
    end
    
    def audio_unit
      @audio_unit ||= (
        au_ptr = FFI::MemoryPointer.new(:pointer)
        require_noerr("AUGraphNodeInfo") {
          AudioToolbox.AUGraphNodeInfo(@graph.graph, @node, nil, au_ptr)
        }
        au = AudioUnit::AudioUnit.new(au_ptr.read_pointer)
        case component_description[:componentType]
        when OSType('aumu')
          au.extend(AudioUnit::MusicDevice)
        end
        au
        )
    end
    
    def component_description
      @component_description ||= (
        cd_ptr = FFI::MemoryPointer.new(ComponentManager::ComponentDescription.size)
        require_noerr("AUGraphNodeInfo") {
          AudioToolbox.AUGraphNodeInfo(@graph.graph, @node, cd_ptr, nil)
        }
        ComponentManager::ComponentDescription.new(cd_ptr))
    end
    
    def to_i
      @node
    end
  end
end