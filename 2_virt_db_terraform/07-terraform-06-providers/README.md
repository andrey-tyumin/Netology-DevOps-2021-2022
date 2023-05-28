
### Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   
      #### Ответ:  
      [ResourcesMap](https://github.com/hashicorp/terraform-provider-aws/blob/2324b148b7c1a0e4a5dd33b0627349485deb6878/aws/provider.go#L459)  
      [DataSourcesMap](https://github.com/hashicorp/terraform-provider-aws/blob/2324b148b7c1a0e4a5dd33b0627349485deb6878/aws/provider.go#L186)  
1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 

    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
      #### Ответ:  
      https://github.com/hashicorp/terraform-provider-aws/blob/2324b148b7c1a0e4a5dd33b0627349485deb6878/aws/resource_aws_sqs_queue.go#L99  
      ```
      ConflictsWith: []string{"name_prefix"},
      ```
      
    * Какая максимальная длина имени? 
      #### Ответ:  
      Каких-то ограничений для name в коде  
      (https://github.com/hashicorp/terraform-provider-aws/blob/2324b148b7c1a0e4a5dd33b0627349485deb6878/aws/resource_aws_sqs_queue.go)  
      на длину я не нашел.  
      Ограничение для name есть в документации terrafom  
      (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue),  
      и равно 80 символам.  
      
    * Какому регулярному выражению должно подчиняться имя?  
      #### Ответ: ^[a-zA-Z0-9_-]{1,80}
---

### Задача 2. (Не обязательно) 
В рамках вебинара и презентации мы разобрали как создать свой собственный провайдер на примере кофемашины. 
Также вот официальная документация о создании провайдера: 
[https://learn.hashicorp.com/collections/terraform/providers](https://learn.hashicorp.com/collections/terraform/providers).

1. Проделайте все шаги создания провайдера.
2. В виде результата приложение ссылку на исходный код.
3. Попробуйте скомпилировать провайдер, если получится то приложите снимок экрана с командой и результатом компиляции.   
