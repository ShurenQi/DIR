# Dense Invariant Representation
This repository is an implementation of the method in  
"A principled design of image representation: Towards forensic tasks", *IEEE Transactions on Pattern Analysis and Machine Intelligence*, 2022.  
Code implemented by Shuren Qi ( i@srqi.email ). All rights reserved.

## Overview

Image forensics is a rising topic as the trustworthy multimedia content is critical for modern society. Like other vision-related
applications, forensic analysis relies heavily on the proper image representation. Despite the importance, current theoretical
understanding for such representation remains limited, with varying degrees of neglect for its key role. For this gap, we attempt to
investigate the forensic-oriented image representation as a distinct problem, from the perspectives of theory, implementation, and
application. Our work starts from the abstraction of basic principles that the representation for forensics should satisfy, especially
revealing the criticality of robustness, interpretability, and coverage. At the theoretical level, we propose a new representation
framework for forensics, called dense invariant representation (DIR), which is characterized by stable description with mathematical
guarantees. At the implementation level, the discrete calculation problems of DIR are discussed, and the corresponding accurate and
fast solutions are designed with generic nature and constant complexity. We demonstrate the above arguments on the dense-domain
pattern detection and matching experiments, providing comparison results with state-of-the-art descriptors. Also, at the application
level, the proposed DIR is initially explored in passive and active forensics, namely copy-move forgery detection and perceptual
hashing, exhibiting the benefits in fulfilling the requirements of such forensic tasks.

