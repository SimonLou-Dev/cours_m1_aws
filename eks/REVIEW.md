# Review EKS Node Group

## Problème bloquant — IAM role partagé entre cluster et node group

Dans `12-k_cluster.tf`, le node group utilise le même role que le cluster :

```hcl
node_role_arn = aws_iam_role.cluster.arn  # ← mauvais
```

Le cluster a `eks.amazonaws.com` comme principal et `AmazonEKSClusterPolicy`.
Les nodes ont besoin d'un role **séparé** avec `ec2.amazonaws.com` comme principal et les policies :

- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`

Sans ça, les nodes ne pourront pas rejoindre le cluster.

---

## Le `aws_launch_template` n'est pas utilisé

Le launch template est défini mais le node group ne le référence pas (block `launch_template {}` manquant).
Il est donc complètement ignoré.

```hcl
# Dans le node group, il faudrait ajouter :
launch_template {
  id      = aws_launch_template.bye_kevin_template.id
  version = aws_launch_template.bye_kevin_template.latest_version
}
```

---

## `remote_access` sans security group

```hcl
remote_access {
  ec2_ssh_key = aws_key_pair.deployer.key_name
  # source_security_group_ids manquant → SSH ouvert à 0.0.0.0/0
}
```

Sans `source_security_group_ids`, AWS ouvre le port 22 à tout internet sur les nodes.

---

## Pas de `depends_on` sur le node group

Le node group devrait attendre les policy attachments du node role (quand il sera créé).

```hcl
depends_on = [
  aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
  aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
  aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
]
```

---

## Ce qui est bien

- Nodes dans les **subnets privés** ✓
- `authentication_mode = "API"` (moderne, sans ConfigMap) ✓
- `scaling_config` avec min/max/desired ✓
- Version EKS explicite (`1.31`) ✓
