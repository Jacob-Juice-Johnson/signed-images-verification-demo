# Gatekeeper & OPA Example

This repository demonstrates the use of [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) and [Gatekeeper](https://open-policy-agent.github.io/gatekeeper/), two powerful tools for enforcing policies in Kubernetes clusters.

## What is OPA?
Open Policy Agent (OPA) is a general-purpose policy engine that enables unified, context-aware policy enforcement across the stack. OPA allows you to write policies in a high-level declarative language called Rego, and can be integrated with various systems, including Kubernetes.

## What is Gatekeeper?
Gatekeeper is a Kubernetes admission controller that uses OPA to enforce policies on resources as they are created or updated in the cluster. Gatekeeper allows you to define and manage policies as Kubernetes resources, making policy enforcement native to Kubernetes workflows.

## Example Files
This repository includes two example files to demonstrate how Gatekeeper works:

### 1. `basic-constrainttemplate.yml`
This file defines a **ConstraintTemplate**, which is a reusable policy definition written in Rego. ConstraintTemplates specify the logic for a policy and the parameters that can be configured by constraints. In this example, the template provides a basic structure for a policy that can be enforced by Gatekeeper.

### 2. `basic-constraint.yml`
This file defines a **Constraint** that uses the above ConstraintTemplate. Constraints are the actual policy instances that Gatekeeper enforces. They reference a ConstraintTemplate and provide specific parameter values for enforcement. In this example, the constraint applies the logic defined in the template to resources in the cluster.

## How to Use
1. **Install Gatekeeper** in your Kubernetes cluster by following the [official documentation](https://open-policy-agent.github.io/gatekeeper/website/docs/install/).
2. **Apply the ConstraintTemplate**:
   ```sh
   kubectl apply -f basic-constrainttemplate.yml
   ```
3. **Apply the Constraint**:
   ```sh
   kubectl apply -f basic-constraint.yml
   ```
4. Gatekeeper will now enforce the policy defined in the template, using the parameters specified in the constraint.

## References
- [OPA Documentation](https://www.openpolicyagent.org/docs/latest/)
- [Gatekeeper Documentation](https://open-policy-agent.github.io/gatekeeper/website/docs/)

---
This example provides a starting point for using OPA and Gatekeeper to enforce custom policies in your Kubernetes environment.
