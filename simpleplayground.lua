require "nn"
mlp = nn.Sequential();  -- make a multi-layer perceptron
inputs = 10; outputs = 1; HUs = 20; -- parameters
mlp:add(nn.Linear(inputs, HUs))
mlp:add(nn.Tanh())
mlp:add(nn.Linear(HUs, outputs))

local PainCriterion, parent = torch.class('nn.PainCriterion', 'nn.Criterion')

function PainCriterion:__init()
   parent.__init(self)
   self.sizeAverage = true
end

function PainCriterion:calc(input, target)
   return input[1]
end

function PainCriterion:forward(input, target)
   self.output = self.calc(input, target)
   return self.output
end

function PainCriterion:backward(input, target)
   grad = torch.Tensor(1)
   grad[1] = -1. * self.calc(input, target)
   return grad
end

criterion = nn.PainCriterion()

for i = 1,2500 do
  -- random sample
  local input= torch.randn(10);     -- normally distributed example in 2d
  local output= torch.Tensor(1);
  output[1] = 100;

  -- feed it to the neural network and the criterion
  criterion:forward(mlp:forward(input), output)

  -- train over this example in 3 steps
  -- (1) zero the accumulation of the gradients
  mlp:zeroGradParameters()
  -- (2) accumulate gradients
  mlp:backward(input, criterion:backward(mlp.output, output))
  -- (3) update parameters with a 0.01 learning rate
  mlp:updateParameters(0.01)
end

x = torch.randn(10)
print(mlp:forward(x));