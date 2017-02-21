2.1 PROJECT OBJECTIVE

/* state clearly the objective of your project – what do you want to accomplish with you proposed system. How are you planning to solve the problem described above*/?
/ State clearly what are the perceived benefits to using your system /

The objective of this project is to create a Rule Based System (RBS) which provides easy access to the public pool for obtaining expert advice for suspected cases of diabetes. The main motivation for creating this expert system is that in recent decades we noticed that there is a significant rise of inadequate access to professional medical healthcare in developing countries and this problem can result in serious health repercussion if the patient was not aware of its health condition in the early stage of diagnosis and how to control it.

To accomplish the proposed system, we will be using CLIPS to code the expert advice acquired during the knowledge acquisition stage. We will then apply the knowledge domain acquired from the SME (Subject Matter Expert) into multiple set of rules stored into the knowledge base. From there once triggered, facts will be applied and rules will be fired accordingly from the inference engine. We can further improve the system by adding/updating new rules through newly acquired knowledge or by using certainty factor (CF) to deal with uncertainties.

The benefits of using the expert system will be that it will give unbiased consistent results based on expert opinion since it is fired based on the programmed rules given by the experts themselves and also through comprehensive study of best practices guidelines and recommendation. We also want to make our expert system to be low cost so that it is easily affordable and with an ease of use computer interface for easy interaction with the end-users for those who is deprived of professional medical care.


3.0 KNOWLEDGE MODELING

/* put all your acquired knowledge here with the modeling diagrams – a picture is worth a thousand words!
You must organize them in a logical and intuitive way to facilitate a clear understanding of the domain */

To acquire the relevant expert knowledge for this project, we have interviewed the relevant SME (Subject Matter Expert) from Diabetes & Metabolism Centre (DMC) – Singapore General Hospital. Throughout the interview, we have gather very useful expert knowledge relevant to the diagnosis of diabetes patient. There is also an intensive study on the MOH website on their diabetes mellitus (summary booklet) clinical practice guidelines and also the different levels of evidence and grades of recommendation.

The process of the knowledge acquisition is not only tedious but also presented some huge challenge as we soon start to realized that different country the medical procedure context is different and we need to find a way to narrow down and standardized to the rules that we want to create in our system.

We have also derived an inference diagram and the attribute value worksheet to further illustrate the different inferable/observable sub goals mainly under symptoms, risk factor and testing while having many observable attributes that falls under the inferable sub goals. A decision tree was also used to provide important insights based on the SME describing certain rules and the respective output preferences based on their expert knowledge and working domain experiences.

The questions that were asked during the knowledge acquisition interview are as follows:

/********* Pending Steven's Word for Word Transcript Qns *************/

In order to deal with uncertainty, certainty factor (CF) was also used in our program to deal with uncertainties associated with the assignment of likelihood values. Such an instance will include if a pregnant patient who does not shows any symptoms but has a history of gestational diabetes or if a user does not enter the test results for Fasting Plasma Glucose (FPG), Casual Plasma Glucose (CPG) or 2-Hour Post Oral Glucose Tolerance Test (OGTT) and shows some risk factors or symptoms. Hence, how we assigned our positive CF values in this case will be based on a certain level of belief on strong evidence and high probability and we will assign a negative value vice-versa.

5.0 CONCLUSION & REFRENCES

/* what have you learnt from this exercise?
What improvement/enhancement can be done to your system? */

In conclusion, we have learnt that diabetes is an epidemic in some parts of the world and diabetes diagnosis can be different in different country context and certain minority groups poses a higher risk of contracting diabetes than others. During the knowledge acquisition stage, we have also grasp a deeper understanding of the types of diabetes and also its symptoms, risk factors and also testing results that determines which classification types. Although diabetes cannot be cure completely, early diagnosis and detection can play a very critical role to prevent future medical complications.

This project also allows the team to learn how by knowledge acquisition can be encapsulated by the knowledge base (KB) and it allows us to experience that knowledge acquisition is not easy and requires the close collaboration and co-operation of both side the SME and the expert system designer. Through the knowledge acquisition process, we also realized that there is some limitation while converting to the rules and based on certain assumptions, we will need to apply the certainty factor (CF) to deal with uncertainties.

The future long term improvement or enhancement that can be done to our current expert system will be to integrate our existing knowledge base rules to further include recommendation for a particular or natural treatment method and diet recommendation based on the diagnosis type results and the patients profile. This enhancement will further require the expert knowledge of diabetes doctors and also the dietician or a nutritionist. Not restricting to just diabetes diagnosis, we can further broaden the spectrum by extending to various diseases depending on pathological interpretations. Hence, such an expert system will advise the patient on the necessary information about indications, diagnosis, treatment and also diet in the comfort of their homes without the need to rely on long waiting time in the clinics or hospital.

/ list all your references /
/ Your 10-page report ends here /
