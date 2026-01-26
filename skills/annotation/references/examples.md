# Annotation Examples

综合示例，展示各场景的注释规范实践。

## Example 1: 科研代码 - 扩散模型去噪

```python
class DiffusionDenoiser(nn.Module):
    """扩散模型去噪网络。

    基于 DDPM 框架，预测噪声 ε_θ(x_t, t, c)。

    Attributes:
        hidden_dim: 隐藏层维度。
        num_layers: Transformer 层数。
        time_embed_dim: 时间步嵌入维度。

    Notes:
        符号映射（对应 [Ho 2020] DDPM）：
            - self.time_mlp → γ(t)，时间嵌入
            - self.net → ε_θ，噪声预测网络
            - forward 输出 → ε_θ(x_t, t, c)
    """

    def forward(
        self,
        x_t: torch.Tensor,      # Shape: (B, C, H, W). 当前噪声样本
        t: torch.Tensor,        # Shape: (B,). 时间步。Range: [0, T-1]
        cond: torch.Tensor      # Shape: (B, D). 条件向量
    ) -> torch.Tensor:
        """预测噪声。

        Args:
            x_t: 时间步 t 的噪声样本。Shape: (B, C, H, W)。已归一化到 [-1, 1]。
            t: 离散时间步。Shape: (B,)。Range: [0, T-1]。
            cond: 条件信息（如抓取姿态编码）。Shape: (B, D)。

        Returns:
            预测的噪声 ε_θ。Shape: (B, C, H, W)。

        Notes:
            数学推导：
                x_t = √(ᾱ_t)·x_0 + √(1-ᾱ_t)·ε
                网络学习预测 ε，训练损失 L = ||ε - ε_θ||²

            参考：
                - [Ho 2020] Denoising Diffusion Probabilistic Models, Eq. (11)
        """
        t_emb = self.time_mlp(t)  # (B, time_embed_dim)
        return self.net(x_t, t_emb, cond)
```

## Example 2: 工程代码 - 点云采样

```python
def farthest_point_sampling(
    points: np.ndarray,
    num_samples: int
) -> tuple[np.ndarray, np.ndarray]:
    """最远点采样（FPS）。

    Args:
        points: 输入点云。Shape: (N, 3)。Unit: meters。
        num_samples: 采样点数。Must be in [1, N]。

    Returns:
        sampled_points: 采样后的点云。Shape: (num_samples, 3)。
        indices: 采样点的原始索引。Shape: (num_samples,)。

    Raises:
        ValueError: num_samples > N 或 num_samples < 1。

    Contracts:
        - Pre: points.shape[0] >= num_samples
        - Post: sampled_points 中的点两两最远点距离最大化

    Notes:
        复杂度：
            - 时间：O(N × num_samples)
            - 空间：O(N)

        边界情况：
            - num_samples == N: 返回原始点云（顺序可能不同）
            - 重复点：可能导致距离为 0，但不影响正确性

        参考：
            - [Qi 2017] PointNet++, Sec. 3.2
    """
```

## Example 3: 配置类 - 训练超参数

```python
@dataclass
class GraspDiffusionConfig:
    """抓取扩散模型训练配置。

    Attributes:
        # === 模型架构 ===
        hidden_dim: Transformer 隐藏维度。Default: 256。
            来源：消融实验 Table 3。128→256 精度 +2.1%。

        num_layers: Transformer 层数。Default: 6。Range: [4, 12]。
            来源：[Vaswani 2017] 建议。过深会过拟合小数据集。

        # === 扩散过程 ===
        num_timesteps: 扩散步数 T。Default: 1000。
            来源：[Ho 2020] DDPM 标准设置。

        beta_schedule: 噪声调度类型。Default: "cosine"。
            Options: "linear", "cosine", "sqrt"。
            来源：[Nichol 2021] 推荐 cosine。

        # === 训练 ===
        lr: 学习率。Default: 1e-4。Range: [1e-5, 1e-3]。
            来源：消融实验。与 batch_size=64 配合最优。

        batch_size: 批大小。Default: 64。
            约束：受 GPU 显存限制（24GB → max 64）。

    Notes:
        跨字段约束：
            - 如增大 batch_size，应相应降低 lr
            - num_timesteps 增大时，训练时间线性增长

        推荐配置：
            - 快速实验：hidden_dim=128, num_layers=4, num_timesteps=100
            - 生产训练：使用默认值
    """
    hidden_dim: int = 256
    num_layers: int = 6
    num_timesteps: int = 1000
    beta_schedule: str = "cosine"
    lr: float = 1e-4
    batch_size: int = 64
```

## Example 4: 实现注释

```python
def compute_grasp_reward(
    contact_points: torch.Tensor,
    object_pose: torch.Tensor
) -> torch.Tensor:
    # === Step 1: 接触点有效性检查 ===
    # 为什么检查接触数：少于 3 个接触点无法形成稳定抓取
    valid_mask = (contact_points > 0).sum(dim=-1) >= 3

    # === Step 2: 计算力闭合分数 ===
    # 参考 [Ferrari 1992] 力闭合理论
    # 简化实现：仅检查接触法向是否覆盖空间
    force_closure = compute_force_closure(contact_points)  # (B,)

    # === Step 3: 姿态对齐奖励 ===
    # 物体坐标系 → 世界坐标系的变换
    # Convention: object_pose 使用 wxyz 四元数
    alignment = compute_alignment(object_pose)  # (B,)

    # 奖励聚合
    # 权重来源：消融实验 Fig. 5
    reward = 0.6 * force_closure + 0.4 * alignment

    # WARN: 无效抓取给予负奖励而非零奖励
    # 原因：零奖励无法区分"无效"和"刚好零分"
    reward = torch.where(valid_mask, reward, torch.full_like(reward, -1.0))

    return reward
```
