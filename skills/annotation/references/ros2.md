# ROS2 注释规范

覆盖 launch 文件（Python/XML）和配置文件（YAML）。

## Launch 文件（Python）

### 文件头

```python
#!/usr/bin/env python3
"""<Launch 文件名> - <功能描述>

功能: <详细说明启动的节点和配置>
依赖: <ROS2 包和外部依赖>
用法: ros2 launch <package> <launch_file> [args]

参数:
    <arg_name>: <说明>。Default: <值>。
"""
```

### 参数声明

```python
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration

def generate_launch_description():
    # === 参数声明 ===
    
    # 仿真频率：物理引擎步长要求 60Hz 以上才能稳定
    sim_hz_arg = DeclareLaunchArgument(
        'sim_hz',
        default_value='60.0',
        description='Simulation frequency in Hz. Must be >= 60 for stable physics.'
    )
    
    # 是否启用 GUI：调试时开启，正式训练时关闭以节省资源
    use_gui_arg = DeclareLaunchArgument(
        'use_gui',
        default_value='false',
        description='Enable visualization GUI. Disable for headless training.'
    )
```

### 节点配置

```python
from launch_ros.actions import Node

def generate_launch_description():
    # === 节点定义 ===
    
    # 抓取规划器：接收点云，输出抓取姿态
    grasp_planner = Node(
        package='dro_grasp',
        executable='grasp_planner',
        name='grasp_planner',
        parameters=[{
            # 推理 batch size：显存 8GB 时最大 16
            'batch_size': 8,
            # 置信度阈值：低于此值的抓取会被过滤
            'confidence_threshold': 0.7,
        }],
        remappings=[
            # 话题重映射：适配 realsense 相机的话题命名
            ('point_cloud', '/camera/depth/color/points'),
        ],
    )
```

### 生命周期和事件

```python
from launch.actions import RegisterEventHandler
from launch.event_handlers import OnProcessStart, OnProcessExit

# 节点启动顺序：先启动仿真，等待 5s 后再启动控制器
# 理由：仿真需要时间加载场景和资产
sim_started = RegisterEventHandler(
    OnProcessStart(
        target_action=sim_node,
        on_start=[
            TimerAction(
                period=5.0,  # 等待仿真初始化
                actions=[controller_node],
            )
        ],
    )
)
```

## Launch 文件（XML）

```xml
<?xml version="1.0"?>
<!--
  <Launch 文件名> - <功能描述>
  
  功能: <说明>
  用法: ros2 launch <package> <file.launch.xml> [args]
-->

<launch>
  <!-- === 参数 === -->
  <!-- 仿真频率：物理引擎要求 >= 60Hz -->
  <arg name="sim_hz" default="60.0" description="Simulation frequency"/>
  
  <!-- === 节点 === -->
  <!-- 抓取规划器 -->
  <node pkg="dro_grasp" exec="grasp_planner" name="grasp_planner">
    <!-- batch size：8GB 显存最大 16 -->
    <param name="batch_size" value="8"/>
  </node>
</launch>
```

## 配置文件（YAML）

### 节点参数配置

```yaml
# <node_name> 配置
# 
# 配置说明: <概述配置内容>
# 使用方法: ros2 param load <node> <file>

/grasp_planner:
  ros__parameters:
    # === 推理配置 ===
    
    # 模型路径：相对于 install 目录
    model_path: "share/dro_grasp/models/best.pth"
    
    # 推理 batch size
    # 显存限制：8GB → 16, 24GB → 64
    batch_size: 16
    
    # 置信度阈值：过滤低置信抓取
    # 来源：验证集 F1-score 最优点
    confidence_threshold: 0.7
    
    # === 话题配置 ===
    
    # 输入点云话题
    input_topic: "/camera/depth/color/points"
    
    # 输出抓取姿态话题
    output_topic: "/grasp_poses"
```

### 控制器配置

```yaml
# 机械臂控制器配置
# 
# 硬件: Franka Panda
# 控制频率: 1000 Hz（Franka 要求）

controller_manager:
  ros__parameters:
    update_rate: 1000  # Hz，Franka 硬件要求
    
    # 加载的控制器列表
    joint_state_broadcaster:
      type: joint_state_broadcaster/JointStateBroadcaster
    
    # 笛卡尔阻抗控制器：柔顺抓取必需
    cartesian_impedance_controller:
      type: franka_example_controllers/CartesianImpedanceController

cartesian_impedance_controller:
  ros__parameters:
    # 刚度参数（N/m 和 Nm/rad）
    # 值来源：Franka 官方推荐 + 抓取任务调优
    translational_stiffness: 200.0  # 平移刚度
    rotational_stiffness: 10.0      # 旋转刚度
```

## 模板

### Launch 文件

```python
#!/usr/bin/env python3
"""<文件名> - <功能>

功能: <说明>
依赖: <包名>
用法: ros2 launch <pkg> <file> [args]
"""

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch_ros.actions import Node

def generate_launch_description():
    # === 参数 ===
    arg = DeclareLaunchArgument(
        'name',
        default_value='value',
        description='说明'
    )
    
    # === 节点 ===
    node = Node(
        package='pkg',
        executable='exec',
        parameters=[{'key': 'value'}],  # 参数说明
    )
    
    return LaunchDescription([arg, node])
```

### 配置文件

```yaml
# <配置文件名> - <功能>
# 
# 适用节点: <node_name>
# 修改说明: <注意事项>

/node_name:
  ros__parameters:
    # === Section ===
    param: value  # <含义>。来源: <...>。
```
