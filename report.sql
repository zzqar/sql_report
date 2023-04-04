SELECT 
     
  pays.id_pay,
     created_at_pay ,
		 payments_date,
    (SELECT name  FROM `crm`.`insurance_companies`WHERE id = branch_id ) branch,
		 (SELECT login FROM mivio_users u  where u.id_user =  pay_user_id  )  created_user_id,
     
 (SELECT name FROM mediline_doctor_groups g WHERE id = 	 (SELECT id_doctor_group FROM medical_service_doctor_group d WHERE d.id_service = cpp.object_id)) as dep_id,
		 (SELECT code FROM medical_services s WHERE s.id_service = cpp.object_id ) code,
		 cpp.object_text_name as position,
		 
		 quantity,
		 
     cpp.total_after_discount/100 as sum ,
		 ROUND( cpp.total_after_discount / sum_for_pay * amount/100 , 2 )as opl,
     ROUND(cpp.total_after_discount / sum_for_pay * overdraft/100 ,2)  as overdraft,
     ROUND(cpp.total_after_discount / sum_for_pay * card/100 ,2)     as card,
     ROUND(cpp.total_after_discount / sum_for_pay * cash/100 ,2)       as cash,
     ROUND(cpp.total_after_discount / sum_for_pay * bill/100 ,2)     as bill,
     ROUND(cpp.total_after_discount / sum_for_pay * other/100 ,2)      as other
  FROM
     (
      SELECT 
          cp.id as id_pay,
          cp.created_at as created_at_pay,
					cp.payments_date,
          cp.created_user_id as pay_user_id,
          cp.branch_id as branch_id,
          cp.client_id as client_id,
          cp.total_after_discount as sum_for_pay,
					
					 cp.total_after_discount * ( SUM(             amount  ) / SUM(amount) )  amount,
          cp.total_after_discount * ( SUM(IF(provider = 'OverdraftProvider',                  amount, 0)) / SUM(amount) )  as overdraft,
          cp.total_after_discount * ( SUM(IF(provider = 'card',                        amount, 0)) / SUM(amount) )  as card,
          cp.total_after_discount * ( SUM(IF(provider = 'cash',                        amount, 0)) / SUM(amount) )  as cash,
          cp.total_after_discount * ( SUM(IF(provider = 'bill',                        amount, 0)) / SUM(amount) )  as bill,
          cp.total_after_discount * ( SUM(IF(provider not in ('bill', 'OverdraftProvider', 'cash', 'card'), amount, 0)) / SUM(amount) )  as other
       FROM 
           cashbox_pays cp
           left JOIN cashbox_payments_pays cpp
                 on cp.id = cpp.pay_id
           left JOIN cashbox_payments cpayments
                 on cpp.payment_id = cpayments.id      
			WHERE cp.`status` not in (12,6,5) 

       GROUP BY pay_id 
      ) as pays
      INNER JOIN cashbox_pays_positions cpp 
           on cpp.pay_id = pays.id_pay and cpp.delete_date is null
JOIN medical_services s on s.id_service = cpp.object_id
	 WHERE cpp.object = 'medical_services'
 and  s.is_product = 0
	and created_at_pay  >= '2022-12-01'
	and created_at_pay  <'2023-01-01'

