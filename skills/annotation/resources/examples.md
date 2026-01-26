# Annotation Examples (Python + IsaacLab)

## Example 1: Function with Contracts + Notes

```python
def compute_quat_angle_error(q_pred: torch.Tensor, q_tgt: torch.Tensor, eps: float = 1e-6) -> torch.Tensor:
    """Compute the rotation angle error between predicted and target quaternions.

    Args:
        q_pred: Predicted quaternion(s). Shape: (N, 4). Convention: wxyz. Must be normalized.
        q_tgt: Target quaternion(s). Shape: (N, 4). Convention: wxyz. Must be normalized.
        eps: Numerical stability constant used in normalization/clamping. Must be > 0.

    Returns:
        Rotation angle error in radians. Shape: (N,). Range: [0, pi].

    Raises:
        ValueError: If eps <= 0.
        ValueError: If q_pred or q_tgt has invalid shape.

    Notes:
        Goal:
            Provide a stable scalar angle error suitable for reward shaping or metrics.

        Definitions:
            - Let $$q_\Delta = q_\mathrm{tgt}^{-1} \otimes q_\mathrm{pred}$$.
            - Angle: $$\theta = 2 \arccos(\mathrm{clip}(q_{\Delta,w}, -1, 1))$$.

        Algorithm (pseudocode):
            1) validate shapes and eps
            2) normalize quaternions (avoid divide-by-zero with eps)
            3) compute relative quaternion q_delta
            4) compute angle via acos with clipping
            5) return theta

        Edge cases:
            - If quaternions are nearly identical, theta ~ 0 (stable under clipping).
    """
    ...
```

## Example 2: Implementation Comments (Frames/Units)

```python
# Convert target pose from world frame to robot base frame.
# Contract:
# - Positions are in meters.
# - Orientations are quaternions in wxyz.
# - Output pose is expressed in the robot base frame.
T_base_world = T_world_base.inverse()
T_base_target = T_base_world @ T_world_target

# Maintain post-condition: reward is finite for every env in the batch.
reward = torch.where(torch.isfinite(reward), reward, torch.zeros_like(reward))
```

## Example 3: Config Object

```python
@dataclass
class RewardTermCfg:
    """Configuration for a single reward term.

    Attributes:
        name: Unique identifier used in registries/logging.
        weight: Scalar multiplier applied to the term. Must be finite.
        clip: Optional symmetric clip applied after weighting. If set, must be > 0.
        enabled: Whether the term contributes to the final reward.

    Notes:
        Contract:
            - If enabled is False, the term must contribute exactly 0.0.
            - If clip is not None, the implementation must clamp to [-clip, clip].
    """
    name: str
    weight: float = 1.0
    clip: float | None = None
    enabled: bool = True
```

## Example 4: Magic Number Justification

```python
# Clamp contact-based reward to avoid rare spikes dominating gradients.
# 10.0 chosen empirically as a "safety ceiling" that preserves learning signal.
contact_reward = torch.clamp(contact_reward, max=10.0)
```
