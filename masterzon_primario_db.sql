-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 09, 2018 at 08:48 AM
-- Server version: 10.0.37-MariaDB
-- PHP Version: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `masterzon_primario_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`masterzon`@`localhost` PROCEDURE `GENERAR_CONTRATO_CESION` (IN `CED_CLIENTE` VARCHAR(50), IN `NUM_OPERACION` VARCHAR(50))  BEGIN
-- Variables donde almacenar lo que nos traemos desde el SELECT
  DECLARE v_cod_contrato INT(5);
  DECLARE v_cod_seccion INT(5);
  DECLARE v_cod_variable VARCHAR(50);
  DECLARE v_des_texto_fijo_seccion VARCHAR(50);
  DECLARE v_control INT(6);
  DECLARE fin INTEGER DEFAULT 0;
 
  
-- El SELECT que vamos a ejecutar
  DECLARE data_cursor CURSOR FOR 
    SELECT V.cod_contrato, V.cod_seccion, V.cod_variable, S.des_texto_fijo_seccion 
    FROM sis_variables_secciones V 
    INNER JOIN sis_secciones_contratos S ON S.cod_tipo_contrato = V.cod_contrato 
    and S.cod_seccion_contrato = V.cod_seccion
    where V.cod_contrato = 1;

-- Condición de salida
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin=1;

  OPEN data_cursor;
  get_data: LOOP
    FETCH data_cursor INTO v_cod_contrato, v_cod_seccion, v_cod_variable,v_des_texto_fijo_seccion;
    IF fin = 1 THEN
       LEAVE get_data;
    END IF;

 call OBTENER_VARIABLES_CONTRATO(v_cod_contrato, v_cod_seccion,v_cod_variable, CED_CLIENTE, NUM_OPERACION) ;
 
 
  END LOOP get_data;

  CLOSE data_cursor;
 
END$$

CREATE DEFINER=`masterzon`@`localhost` PROCEDURE `GENERAR_FACTURA_ESTANDAR` (IN `CED_CLIENTE` VARCHAR(50), IN `NUM_OPERACION` VARCHAR(50), IN `FRACCIONES` INT(1))  BEGIN
-- Variables donde almacenar lo que nos traemos desde el SELECT
  DECLARE v_cod_contrato INT(5);
  DECLARE v_cod_seccion INT(5);
  DECLARE v_cod_variable VARCHAR(50);
  DECLARE v_des_texto_fijo_seccion VARCHAR(50);
  DECLARE v_control INT(6);
  DECLARE fin INTEGER DEFAULT 0;
 
  
-- El SELECT que vamos a ejecutar
  DECLARE data_cursor CURSOR FOR 
    SELECT V.cod_contrato, V.cod_seccion, V.cod_variable, S.des_texto_fijo_seccion 
    FROM sis_variables_secciones V 
    INNER JOIN sis_secciones_contratos S ON S.cod_tipo_contrato = V.cod_contrato 
    and S.cod_seccion_contrato = V.cod_seccion
    where V.cod_contrato = 3;

-- Condición de salida
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin=1;

  OPEN data_cursor;
  get_data: LOOP
    FETCH data_cursor INTO v_cod_contrato, v_cod_seccion, v_cod_variable,v_des_texto_fijo_seccion;
    IF fin = 1 THEN
       LEAVE get_data;
    END IF;

 call OBTENER_VARIABLES_FACTURA_ESTANDAR(v_cod_contrato, v_cod_seccion,v_cod_variable, CED_CLIENTE, NUM_OPERACION, FRACCIONES) ;
 
 
  END LOOP get_data;

  CLOSE data_cursor;
 
END$$

CREATE DEFINER=`masterzon`@`localhost` PROCEDURE `GENERAR_LETRA_CAMBIO` (IN `CED_CLIENTE` VARCHAR(50), IN `NUM_OPERACION` VARCHAR(50))  BEGIN
-- Variables donde almacenar lo que nos traemos desde el SELECT
  DECLARE v_cod_contrato INT(5);
  DECLARE v_cod_seccion INT(5);
  DECLARE v_cod_variable VARCHAR(50);
  DECLARE v_des_texto_fijo_seccion VARCHAR(50);
  DECLARE v_control INT(6);
  DECLARE fin INTEGER DEFAULT 0;
 
  
-- El SELECT que vamos a ejecutar
  DECLARE data_cursor CURSOR FOR 
    SELECT V.cod_contrato, V.cod_seccion, V.cod_variable, S.des_texto_fijo_seccion 
    FROM sis_variables_secciones V 
    INNER JOIN sis_secciones_contratos S ON S.cod_tipo_contrato = V.cod_contrato 
    and S.cod_seccion_contrato = V.cod_seccion
    where V.cod_contrato = 2;

-- Condición de salida
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin=1;

  OPEN data_cursor;
  get_data: LOOP
    FETCH data_cursor INTO v_cod_contrato, v_cod_seccion, v_cod_variable,v_des_texto_fijo_seccion;
    IF fin = 1 THEN
       LEAVE get_data;
    END IF;

 call OBTENER_VARIABLES_LETRA_CAMBIO(v_cod_contrato, v_cod_seccion,v_cod_variable, CED_CLIENTE, NUM_OPERACION) ;
 
 
  END LOOP get_data;

  CLOSE data_cursor;
 
END$$

CREATE DEFINER=`masterzon`@`localhost` PROCEDURE `NOTIFICAR_INGRESO_MEJOR_PUJA` (IN `pNumOperacion` INT(5), IN `pUsuario` VARCHAR(50))  BEGIN
 
DECLARE vrnd_propio decimal(6,2);


SET vrnd_propio = (SELECT  P.num_rendimiento 
								FROM sis_pujas_operaciones P
									INNER JOIN sis_usuarios U ON U.cod_usuario = P.cod_usuario
								WHERE cod_venta = pNumOperacion
									AND P.cod_usuario = pUsuario);
 
 /*se obtiene el vendedor*/
 SELECT U.des_email,1 as codigo 
	FROM sis_usuarios U 
		INNER JOIN sis_operaciones_cooperativas O ON O.cod_vendedor = U.cod_compania
        WHERE O.num_operacion = pNumOperacion
        AND U.ind_alertas_cambios = 'S'
 UNION ALL 
 /*Se obtienen los inversionistas*/
SELECT U.des_email,2 as codigo
    FROM sis_pujas_operaciones P
    INNER JOIN sis_usuarios U ON U.cod_usuario = P.cod_usuario
    WHERE cod_venta = pNumOperacion
    AND P.num_rendimiento > vrnd_propio
    AND P.cod_usuario <> pUsuario
    AND U.ind_alertas_cambios = 'S';
 
 
 END$$

CREATE DEFINER=`masterzon`@`localhost` PROCEDURE `NOTIFICAR_INGRESO_MEJOR_PUJA_P` (IN `pNumOperacion` INT(5), IN `pUsuario` VARCHAR(50))  BEGIN
 
DECLARE vrnd_propio decimal(6,2);


SET vrnd_propio = (SELECT  P.num_rendimiento 
								FROM sis_pujas_operaciones_privadas P
									INNER JOIN sis_usuarios U ON U.cod_usuario = P.cod_usuario
								WHERE cod_venta = pNumOperacion
									AND P.cod_usuario = pUsuario);
 
 /*se obtiene el vendedor*/
 SELECT U.des_email,1 as codigo 
	FROM sis_usuarios U 
		INNER JOIN sis_operaciones_pymes O ON O.cod_vendedor = U.cod_compania
        WHERE O.num_operacion = pNumOperacion
        AND U.ind_alertas_cambios = 'S'
 UNION ALL 
 /*Se obtienen los inversionistas*/
SELECT U.des_email,2 as codigo
    FROM sis_pujas_operaciones_privadas P
    INNER JOIN sis_usuarios U ON U.cod_usuario = P.cod_usuario
    WHERE cod_venta = pNumOperacion
    AND P.num_rendimiento > vrnd_propio
    AND P.cod_usuario <> pUsuario
    AND U.ind_alertas_cambios = 'S';
 
 
 END$$

CREATE DEFINER=`masterzon`@`localhost` PROCEDURE `OBTENER_MONITOREO_PUJAS` ()  NO SQL
SELECT  
	OP.num_operacion as 'oper',
	OP.num_documento as 'doc',
    JD.des_nick_name as 'DeudorPagador',
    MDA.des_tipo_moneda as Moneda,
   
	format(OP.mon_facial,2) as MontoFacial,
	JV.des_nick_name as Proveedor,
    OP.num_rendimiento as 'Rnd_Proveedor',
    format(PH.num_descuento,0) as 'Descuento',
	JC.des_nick_name as Inversionista,
	PH.num_rendimiento as 'Rnd_Inversionista',
    case when OP.ind_operacion_liquidada = 'N' then 'NO' else 'SI' end as LiqOtraMoneda,
    format(TRAER_MONTO_LIQ_COMPRAS(OP.mon_facial,PH.num_rendimiento,PH.num_descuento,OP.cod_tipo_plazo,OP.cod_tipo_moneda,PH.cod_comprador,OP.cod_tipo_factura,OP.ind_operacion_liquidada,1,1),2) as MontoLiquidacion,
    PH.fec_hora_puja
	
 FROM sis_pujas_operaciones PH
	 INNER JOIN sis_operaciones OP ON OP.num_operacion = PH.cod_venta
	 LEFT OUTER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = PH.cod_comprador

	 INNER JOIN sis_catalogo_juridicos JV ON JV.num_identificacion = OP.cod_vendedor
	 INNER JOIN sis_catalogo_juridicos JD ON JD.num_identificacion = OP.cod_deudor
     INNER JOIN sis_tipos_monedas MDA ON MDA.cod_tipo_moneda = OP.cod_tipo_moneda
     order by OP.num_operacion$$

CREATE DEFINER=`masterzon`@`localhost` PROCEDURE `OBTENER_VARIABLES_CONTRATO` (IN `pContrato` INT(5), IN `pSeccion` INT(5), IN `pVariable` VARCHAR(50), IN `CED_CLIENTE` VARCHAR(50), IN `NUM_OPERACION` VARCHAR(50))  NO SQL
    COMMENT 'procedimineto utilizado en la generacion de contratos de cesion'
BEGIN
  
SET @QueryString = (SELECT CASE WHEN des_query_dato LIKE '%CED_CLIENTE%'  OR des_query_dato LIKE '%NUM_OPERACION%'
							THEN REPLACE(REPLACE(des_query_dato,'CED_CLIENTE',CED_CLIENTE) ,'NUM_OPERACION',NUM_OPERACION)
							 ELSE des_query_dato 
							END result
					FROM sis_variables_secciones 
                    WHERE cod_contrato = pContrato and cod_seccion = pSeccion and cod_variable = pVariable);
 
 PREPARE smtp FROM @QueryString;
 EXECUTE smtp;
 
 DEALLOCATE PREPARE smtp;
 
END$$

CREATE DEFINER=`masterzon`@`localhost` PROCEDURE `OBTENER_VARIABLES_FACTURA_ESTANDAR` (IN `pContrato` INT(5), IN `pSeccion` INT(5), IN `pVariable` VARCHAR(50), IN `CED_CLIENTE` VARCHAR(50), IN `NUM_OPERACION` VARCHAR(50), IN `FRACCIONES` INT(1))  BEGIN
  
SET @QueryString = (SELECT CASE WHEN des_query_dato LIKE '%CED_CLIENTE%'  OR des_query_dato LIKE '%NUM_OPERACION%'
							THEN REPLACE(REPLACE(REPLACE(des_query_dato,'FRACCIONES',FRACCIONES),'CED_CLIENTE',CED_CLIENTE) ,'NUM_OPERACION',NUM_OPERACION)
							 ELSE des_query_dato 
							END result
					FROM sis_variables_secciones 
                    WHERE cod_contrato = pContrato and cod_seccion = pSeccion and cod_variable = pVariable
                    AND cod_contrato = 3);
 
 PREPARE smtp FROM @QueryString;
 EXECUTE smtp;
 
 DEALLOCATE PREPARE smtp;
 
END$$

CREATE DEFINER=`masterzon`@`localhost` PROCEDURE `OBTENER_VARIABLES_LETRA_CAMBIO` (IN `pContrato` INT(5), IN `pSeccion` INT(5), IN `pVariable` VARCHAR(50), IN `CED_CLIENTE` VARCHAR(50), IN `NUM_OPERACION` VARCHAR(50))  BEGIN
  
SET @QueryString = (SELECT CASE WHEN des_query_dato LIKE '%CED_CLIENTE%'  OR des_query_dato LIKE '%NUM_OPERACION%'
							THEN REPLACE(REPLACE(des_query_dato,'CED_CLIENTE',CED_CLIENTE) ,'NUM_OPERACION',NUM_OPERACION)
							 ELSE des_query_dato 
							END result
					FROM sis_variables_secciones 
                    WHERE cod_contrato = pContrato and cod_seccion = pSeccion and cod_variable = pVariable
                    AND cod_contrato = 2);
 
 PREPARE smtp FROM @QueryString;
 EXECUTE smtp;
 
 DEALLOCATE PREPARE smtp;
 
END$$

--
-- Functions
--
CREATE DEFINER=`masterzon`@`localhost` FUNCTION `CONSULTAR_CALCE_OPERACION` (`pNum_Venta` INT) RETURNS INT(15) BEGIN
DECLARE num_puja numeric(15);
SET num_puja = (SELECT min(P.cod_puja_operacion) 
 FROM `sis_operaciones` O
  INNER JOIN sis_pujas_operaciones P ON 
      O.num_operacion = P.cod_venta
 WHERE num_operacion = 56
  and P.num_rendimiento = O.num_rendimiento
  and P.num_descuento = P.num_descuento);
RETURN num_puja;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `CONTAR_DIAS_HABILES` (`pFechaDesde` DATE, `pFechaHasta` DATE) RETURNS INT(10) BEGIN
DECLARE freedays int;
SET freedays = (SELECT count(cod_feriado) FROM `sis_feriados` where fec_feriado between pFechaDesde and pFechaHasta
               and DAYNAME(fec_feriado) <> 'Saturday'
               and DAYNAME(fec_feriado) <> 'Sunday');
SET @x = DATEDIFF(pFechaHasta, pFechaDesde);
IF @x<0 THEN
SET @m = pFechaDesde;
SET pFechaDesde = pFechaHasta;
SET pFechaHasta = @m;
SET @m = -1;
ELSE
SET @m = 1;
END IF;
SET @x = abs(@x) + 1;
SET @w1 = WEEKDAY(pFechaDesde)+1;
SET @wx1 = 8-@w1;
IF @w1>5 THEN
SET @w1 = 0;
ELSE
SET @w1 = 6-@w1;
END IF;
SET @wx2 = WEEKDAY(pFechaHasta)+1;
SET @w2 = @wx2;
IF @w2>5 THEN
SET @w2 = 5;
END IF;
SET @weeks = (@x-@wx1-@wx2)/7;
SET @noweekends = (@weeks*5)+@w1+@w2;
SET @result = @noweekends-freedays;
RETURN @result*@m;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `DESCIFRAR_VARIABLE` (`pCodSeccion` INT(5), `pCodVariable` VARCHAR(50), `CED_CLIENTE` VARCHAR(50), `NUM_OPERACION` VARCHAR(50)) RETURNS VARCHAR(3000) CHARSET latin1 BEGIN
DECLARE vResultado VARCHAR(3000);


SET vResultado = (SELECT IFNULL(V.des_valor_variable,'???????') as des_valor_variable 
					FROM sis_datos_tmp_contratos V 
						WHERE V.cod_seccion = pCodSeccion
							and V.cod_variable = pCodVariable
							and V.num_identificacion = CED_CLIENTE
							and V.num_operacion = NUM_OPERACION);

RETURN vResultado;

END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `DESCIFRAR_VARIABLE_FACTURA_ESTANDAR` (`pCodSeccion` INT(5), `pCodVariable` VARCHAR(50), `CED_CLIENTE` VARCHAR(50), `NUM_OPERACION` VARCHAR(50)) RETURNS VARCHAR(3000) CHARSET latin1 BEGIN
DECLARE vResultado VARCHAR(3000);


SET vResultado = (SELECT IFNULL(V.des_valor_variable,'???????') as des_valor_variable 
					FROM sis_datos_tmp_factura_estandar V 
						WHERE V.cod_seccion = pCodSeccion
							and V.cod_variable = pCodVariable
							and V.num_identificacion = CED_CLIENTE
							and V.num_operacion = NUM_OPERACION);

RETURN vResultado;

END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `DESCIFRAR_VARIABLE_LETRA_CAMBIO` (`pCodSeccion` INT(5), `pCodVariable` VARCHAR(50), `CED_CLIENTE` VARCHAR(50), `NUM_OPERACION` VARCHAR(50)) RETURNS VARCHAR(3000) CHARSET latin1 NO SQL
BEGIN
DECLARE vResultado VARCHAR(3000);


SET vResultado = (SELECT IFNULL(V.des_valor_variable,'???????') as des_valor_variable 
					FROM sis_datos_tmp_letras_cambio V 
						WHERE V.cod_seccion = pCodSeccion
							and V.cod_variable = pCodVariable
							and V.num_identificacion = CED_CLIENTE
							and V.num_operacion = NUM_OPERACION);

RETURN vResultado;

END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `DIAS_EN_ESPANOL` (`pDia` VARCHAR(15)) RETURNS VARCHAR(15) CHARSET latin1 NO SQL
BEGIN
 
 
  CASE pDia
      WHEN 'Friday' THEN return 'Viernes';
       WHEN 'Tuesday' THEN return 'Martes';
        WHEN 'Wednesday' THEN return 'Miercoles';
         WHEN 'Thursday' THEN return 'Jueves';
          WHEN 'Saturday' THEN return 'Sabado';
           WHEN 'Sunday' THEN return 'Domingo';
      ELSE
        BEGIN
        return 'Lunes';
        END;
    END CASE;

END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `DIA_FERIADO` (`pFecha` DATE) RETURNS TINYINT(1) BEGIN
	DECLARE cant_dat tinyint default 0;

	SET cant_dat = (SELECT count(fec_feriado) FROM sis_feriados where fec_feriado = pFecha);
  
  IF cant_dat > 0 THEN
	RETURN TRUE;
  ELSE
	RETURN FALSE;
  END IF;

END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `FIN_DE_SEMANA` (`pFecha` DATE) RETURNS TINYINT(1) BEGIN
DECLARE weekend_dat varchar(20);

SET weekend_dat = (select DAYNAME(pFecha));

  IF weekend_dat = 'Saturday' OR weekend_dat = 'Sunday' THEN
   RETURN TRUE;
   else
   RETURN FALSE;
   
   END IF;
 
 END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `MESES_EN_ESPANOL` (`pFecha` VARCHAR(15)) RETURNS VARCHAR(15) CHARSET latin1 NO SQL
BEGIN
  
  CASE pFecha
      WHEN 'January' THEN return 'Enero';
       WHEN 'February' THEN return 'Febrero';
        WHEN 'March' THEN return 'Marzo';
         WHEN 'April' THEN return 'Abril';
          WHEN 'May' THEN return 'Mayo';
           WHEN 'June' THEN return 'Junio';
            WHEN 'July' THEN return 'Julio';
             WHEN 'August' THEN return 'Agosto';
              WHEN 'September' THEN return 'Septiembre';
               WHEN 'October' THEN return 'Octubre';
                WHEN 'November' THEN return 'Noviembre';
      ELSE
        BEGIN
        return 'December';
        END;
    END CASE;

END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_COMISION` (`MFL` DECIMAL(20,2), `RND` DECIMAL(3,1), `PJE` INT(3), `PZO` INT(5), `MDA` INT(3), `ID` VARCHAR(50), `TPO` INT(3), `LIQ` CHAR(1), `IND1` INT(3), `IND2` INT(3)) RETURNS DECIMAL(20,2) BEGIN
 DECLARE vResultado NUMERIC(20,2);
 DECLARE vTranzado NUMERIC(20,2);
 /*DECLARE vIntereses NUMERIC(20,2);*/
 DECLARE vPorcentajeCOM NUMERIC(5,2);
 DECLARE vComMinima NUMERIC(20,2);
 DECLARE vTipoCambio DECIMAL(10,2);
  DECLARE vParametro DECIMAL(5,2);
 
 SET vParametro  = (SELECT val_parametro AS MargenProteccion  FROM sis_parametros WHERE cod_parametro =  'SIS025');
 
 
 SET vTipoCambio =	(SELECT  `num_valor` 
						FROM `sis_tipo_cambio_monedas` 
							WHERE fec_tipo_cambio =(SELECT MAX(fec_tipo_cambio) FROM sis_tipo_cambio_monedas WHERE cod_moneda = 2 and cod_fuente = 4 ) 
								and cod_moneda = 2
								and cod_fuente = 4);
 
 		IF MDA <= 0 THEN
        RETURN 1;
        END IF;
        
        
        IF PZO <= 0 THEN
        RETURN 1;
        END IF;
        
        IF RND <= 0 THEN
        RETURN 1;
        END IF;
        
        IF MFL <= 0 THEN
        RETURN 1;
        END IF;
        
        IF PJE <= 0 THEN
        RETURN 1;
        END IF;
        
	IF TPO > 3 THEN
       SET vPorcentajeCOM = (SELECT mon_comision_lending FROM `sis_catalogo_juridicos` J INNER JOIN sis_catalogo_membresias M ON J.cod_tipo_membresia = M.cod_tipo_membresia
															WHERE REPLACE(J.num_identificacion,'-','') = REPLACE(ID,'-','')); 
        ELSE
	   SET vPorcentajeCOM = (SELECT mon_comision_lending FROM `sis_catalogo_juridicos` J INNER JOIN sis_catalogo_membresias M ON J.cod_tipo_membresia = M.cod_tipo_membresia
															WHERE REPLACE(J.num_identificacion,'-','') = REPLACE(ID,'-','')); 
        END IF;
        
     IF PZO > 365 THEN
        set PZO = 365;
        END IF;
 
 
            
SET vTranzado = MFL;
        
SET vResultado = ((vTranzado * (vPorcentajeCOM / 100)) / 365) * PZO;
  
  if (MDA = 1 AND LIQ = 'N' ) OR (MDA = 2 AND LIQ = 'S' ) then
 SET vComMinima =  
 (SELECT (M.mon_comision_minima_dolares * vTipoCambio) AS comision_min
	FROM sis_catalogo_membresias M
		INNER JOIN sis_catalogo_juridicos J ON J.cod_tipo_membresia = M.cod_tipo_membresia
        WHERE REPLACE(J.num_identificacion,'-','') = REPLACE(ID,'-',''));
    ELSE
    
     SET vComMinima =  
 (SELECT M.mon_comision_minima_dolares AS comision_min
	FROM sis_catalogo_membresias M
		INNER JOIN sis_catalogo_juridicos J ON J.cod_tipo_membresia = M.cod_tipo_membresia
        WHERE REPLACE(J.num_identificacion,'-','') = REPLACE(ID,'-',''));
        
  end if;
 

	IF vResultado < vComMinima THEN
         RETURN vComMinima;
        ELSE
         RETURN vResultado;
     END IF;
 
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_DIFERENCIA_HORARIO_USA` () RETURNS TINYINT(4) NO SQL
BEGIN
	DECLARE v_suma_horas tinyint default 0;
     DECLARE v_horario VARCHAR(10);  /*VERANO, INVIERNO*/
 
  
  /**SE ESTABLECE SI EN OREGON (LUGAR DONDE ESTAN LOS SERVIDORES DE MASTERZON) ES HORARIO DE VERANO O INVIERNO*/
	SET v_horario = (SELECT CASE WHEN CURDATE() BETWEEN '2018-03-11' AND '2018-11-04' THEN 'VERANO' ELSE 'INVIERNO' END);
 
  /*DEPENDIENDO DEL HORARIO SE DEBE SUMAR UN O DOS HORAS AL HORARIO PARA TENER LA HORA DE COSTA RICA*/
  IF v_horario = 'VERANO' THEN
	SET v_suma_horas = 1;
  ELSE
	SET v_suma_horas = 2;
  END IF;
 
	
return v_suma_horas;

END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_FECHA_LIQUIDACION` () RETURNS DATE NO SQL
    COMMENT 'funcion que obtiene la fecha de liq. Considera cambio horario US'
BEGIN
	DECLARE v_suma_horas tinyint default 0;
    DECLARE v_hora_servidor time;
    DECLARE v_horario VARCHAR(10);  /*VERANO, INVIERNO*/
    DECLARE v_hora_corte time;
	DECLARE v_resultado DATE;
    DECLARE v_sabado VARCHAR(10);
    DECLARE v_feriado tinyint(1);
    DECLARE v_man_feriado tinyint(1);
  
  /**SE ESTABLECE SI EN OREGON (LUGAR DONDE ESTAN LOS SERVIDORES DE MASTERZON) ES HORARIO DE VERANO O INVIERNO*/
	SET v_horario = (SELECT CASE WHEN CURDATE() BETWEEN '2018-03-11' AND '2018-11-04' THEN 'VERANO' ELSE 'INVIERNO' END);
 
  /*DEPENDIENDO DEL HORARIO SE DEBE SUMAR UN O DOS HORAS AL HORARIO PARA TENER LA HORA DE COSTA RICA*/
  IF v_horario = 'VERANO' THEN
	SET v_suma_horas = 1;
  ELSE
	SET v_suma_horas = 2;
  END IF;

	/*A LA HORA DEL SERVIDOR SE LE SUMA LA DIFERENCIA EN HORAS*/
	SET v_hora_servidor = (SELECT TIME_FORMAT( DATE_ADD(NOW(), INTERVAL v_suma_horas HOUR), '%T'));
    
    SET v_hora_corte = (select TIME_FORMAT(val_parametro, '%T') from sis_parametros where cod_parametro = 'SIS004');
    
		 IF v_hora_servidor > v_hora_corte THEN
			SET v_resultado= (SELECT OBTENER_SIGUIENTE_DIA_HABIL( DATE_ADD( NOW( ) , INTERVAL 1 DAY )));
            
            SET v_feriado = (select DIA_FERIADO(DATE_ADD(v_resultado, INTERVAL 1 DAY))); 
            
            SET v_sabado = (SELECT DATE_FORMAT(DATE_ADD( NOW( ) , INTERVAL 1 DAY ),'%W'));
            
            SET v_man_feriado = (select DIA_FERIADO(DATE_ADD(NOW( ), INTERVAL 1 DAY)));
            
            /*Se revisa si "mañana" es sabado, para determinar si debo mover la fecha un dia adicional hacia adelante*/
            if v_sabado = 'Saturday' OR v_feriado = 1 OR v_man_feriado = 1 then
            SET v_resultado= (SELECT OBTENER_SIGUIENTE_DIA_HABIL( v_resultado ));
            end if;
            
		ELSE
			SET v_resultado= (SELECT OBTENER_SIGUIENTE_DIA_HABIL( DATE_ADD( NOW( ) , INTERVAL 0 DAY )));
		 END IF;
	
return v_resultado;

END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_INTERESES_ACORDADOS` (`RND` DECIMAL(3,1), `MFL` DECIMAL(20,2), `PJE` INT(3), `PZO` INT(5), `MDA` INT(1), `LIQ` CHAR(1), `IND1` INT(3), `IND2` INT(3)) RETURNS DECIMAL(20,2) NO SQL
    COMMENT 'Funcion que obtiene el interes de una factura a un plazo X'
BEGIN
 DECLARE vResultado NUMERIC(15,2);
 DECLARE vTransado NUMERIC(20,2);
 DECLARE vTOTAL NUMERIC(15,2);
 
        IF PZO <= 0 THEN
        RETURN 1;
        END IF;
        
        IF RND <= 0 THEN
        RETURN 1;
        END IF;
        
        IF MFL <= 0 THEN
        RETURN 1;
        END IF;
        
        IF PJE <= 0 THEN
        RETURN 1;
        END IF;
        
        SET vTransado = TRAER_MONTO_TRANSADO(MFL,RND,PZO,PJE,MDA,LIQ,IND1,IND2);        
        
        SET vResultado = (vTransado * (RND /100) / 365 * PZO);
        
	RETURN vResultado;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_INTERESES_NETOS_COMPRA` (`MFL` DECIMAL(20,2), `RND` DECIMAL(3,1), `PJE` INT(3), `PZO` INT(5), `MDA` INT(3), `ID` VARCHAR(50), `TPO` INT(3), `LIQ` CHAR(1), `IND1` INT(3), `IND2` INT(3)) RETURNS DECIMAL(20,2) NO SQL
    COMMENT 'Funcion que obtiene los intereses netos p/ el inversionista'
BEGIN
 DECLARE vResultado NUMERIC(20,2);
 DECLARE vPrincipal NUMERIC(20,2);
 DECLARE vIntereses NUMERIC(20,2);
 DECLARE vComision NUMERIC(20,2);
 
 		IF MDA <= 0 THEN
        RETURN 1;
        END IF;
        
        IF PZO <= 0 THEN
        RETURN 1;
        END IF;
        
        IF RND <= 0 THEN
        RETURN 1;
        END IF;
        
        IF MFL <= 0 THEN
        RETURN 1;
        END IF;
        
        IF PJE <= 0 THEN
        RETURN 1;
        END IF;
        
    SET vComision = OBTENER_COMISION (MFL,RND,PJE,PZO,MDA,ID,TPO,LIQ,IND1,IND2);
        
	SET vIntereses = OBTENER_INTERESES_ACORDADOS (RND,MFL,PJE,PZO,MDA,LIQ,IND1,IND2);
        
	SET vResultado = vIntereses - vComision;
         
    RETURN vResultado;
    
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_INTERESES_NETOS_VENTA` (`MFL` DECIMAL(20,2), `RND` DECIMAL(3,1), `PJE` INT(3), `PZO` INT(5), `MDA` INT(3), `ID` VARCHAR(50), `TPO` INT(3), `LIQ` CHAR(1), `IND1` INT(3), `IND2` INT(3)) RETURNS DECIMAL(20,2) NO SQL
    COMMENT 'Funcion que obtiene los intereses netos del proveedor'
BEGIN
 DECLARE vResultado NUMERIC(20,2);
 DECLARE vPrincipal NUMERIC(20,2);
 DECLARE vIntereses NUMERIC(20,2);
 DECLARE vComision NUMERIC(20,2);
 
 		IF MDA <= 0 THEN
        RETURN 1;
        END IF;
        
        IF PZO <= 0 THEN
        RETURN 1;
        END IF;
        
        IF RND <= 0 THEN
        RETURN 1;
        END IF;
        
        IF MFL <= 0 THEN
        RETURN 1;
        END IF;
        
        IF PJE <= 0 THEN
        RETURN 1;
        END IF;
        
    SET vComision = OBTENER_COMISION (MFL,RND,PJE,PZO,MDA,ID,TPO,LIQ,IND1,IND2);
        
	SET vIntereses = OBTENER_INTERESES_ACORDADOS (RND,MFL,PJE,PZO,MDA,LIQ,IND1,IND2);
        
    SET vResultado = vIntereses + vComision;
         
    RETURN vResultado;
    
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_OPERACIONES_EN_PIZARRA` () RETURNS INT(5) BEGIN
   
  DECLARE vMin_Oper int(5);
 
   
   /*Inserta las operaciones publicadas y que tienen almenos 4 pujas en pizarra**/
    INSERT INTO grf_orden_dashboard_factoring 
		  SELECT O.num_operacion,'N',0 FROM sis_operaciones O 
		   INNER JOIN sis_pujas_operaciones_hist H ON H.cod_venta = O.num_operacion
		   WHERE O.cod_estado = 4
			and (select COUNT(cod_puja_operacion) FROM sis_pujas_operaciones_hist where cod_venta = O.num_operacion) > 1
		   group by O.num_operacion;
 
 /*Obtiene el numero mas bajo de operacion en la tabla de operaciones graficadas*/
	SET vMin_Oper = (SELECT min(num_operacion) from grf_orden_dashboard_factoring);
  
  /*Activa la opracion con numero mas bajo para iniciar el carrusel*/
	UPDATE grf_orden_dashboard_factoring
		SET ind_actividad = 'S'
         where num_operacion = vMin_Oper;
    
  /*Actualiza el parametro con el nuevo numero de operacon*/
	  UPDATE sis_parametros	  set val_parametro = vMin_Oper	, fec_modificacion = now()  where cod_parametro = 'SIS029';
 

    
RETURN vMin_Oper;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_PUJA_OPTIMA` (`pNum_Venta` INT) RETURNS INT(15) BEGIN
 DECLARE select_var numeric(15);
 /*FUNCION que obtiene el menor rendimiento, con el mayor porcentaje de descuento, y con la fecha/hora menor. Devuelve el codigo (pk) de la puja.*/
 SET select_var = (SELECT tbl2.PUJA
					FROM
							(SELECT 
								tbl.cod_puja PUJA,
								tbl.fecha_hora FECHA
							FROM 
								 (Select 
										cod_puja_operacion  cod_puja,
										num_rendimiento rendimiento,
										max(num_descuento) porcentaje,
										fec_hora_puja fecha_hora 
									FROM sis_pujas_operaciones 
                                    WHERE
											cod_venta = pNum_Venta and 	
											num_rendimiento = (SELECT min(num_rendimiento) FROM sis_pujas_operaciones WHERE cod_venta = pNum_Venta)
									GROUP BY cod_puja_operacion ,fec_hora_puja ) tbl
							WHERE 	tbl.porcentaje = (Select max(num_descuento) FROM sis_pujas_operaciones WHERE cod_venta = pNum_Venta and 	
									num_rendimiento = (SELECT min(num_rendimiento) FROM sis_pujas_operaciones WHERE cod_venta = pNum_Venta)) ) tbl2
					WHERE tbl2.FECHA = (SELECT min(tbl.fecha_hora) FECHA 
										FROM  (Select 	
														cod_puja_operacion  cod_puja,
														num_rendimiento rendimiento,
														max(num_descuento) porcentaje,
														fec_hora_puja fecha_hora 
													FROM sis_pujas_operaciones 
                                                    WHERE
															cod_venta = pNum_Venta and 	
															num_rendimiento = (SELECT min(num_rendimiento) FROM sis_pujas_operaciones WHERE cod_venta = pNum_Venta)
													GROUP BY cod_puja_operacion ,fec_hora_puja ) tbl
										WHERE 	tbl.porcentaje = (Select max(num_descuento) FROM sis_pujas_operaciones WHERE cod_venta = pNum_Venta and 	
												num_rendimiento = (SELECT min(num_rendimiento) FROM sis_pujas_operaciones WHERE cod_venta = pNum_Venta))));
		RETURN select_var;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_PUJA_OPTIMA_PRIVADA` (`pNum_Venta` INT) RETURNS INT(15) BEGIN
 DECLARE select_var numeric(15);
 /*FUNCION que obtiene el menor rendimiento, con el mayor porcentaje de descuento, y con la fecha/hora menor. Devuelve el codigo (pk) de la puja.*/
 SET select_var = (SELECT tbl2.PUJA
					FROM
							(SELECT 
								tbl.cod_puja PUJA,
								tbl.fecha_hora FECHA
							FROM 
								 (Select 
										cod_puja_operacion  cod_puja,
										num_rendimiento rendimiento,
										max(num_descuento) porcentaje,
										fec_hora_puja fecha_hora 
									FROM sis_pujas_operaciones_privadas
                                    WHERE
											cod_venta = pNum_Venta and 	
											num_rendimiento = (SELECT min(num_rendimiento) FROM sis_pujas_operaciones_privadas WHERE cod_venta = pNum_Venta)
									GROUP BY cod_puja_operacion ,fec_hora_puja ) tbl
							WHERE 	tbl.porcentaje = (Select max(num_descuento) FROM sis_pujas_operaciones_privadas WHERE cod_venta = pNum_Venta and 	
									num_rendimiento = (SELECT min(num_rendimiento) FROM sis_pujas_operaciones_privadas WHERE cod_venta = pNum_Venta)) ) tbl2
					WHERE tbl2.FECHA = (SELECT min(tbl.fecha_hora) FECHA 
										FROM  (Select 	
														cod_puja_operacion  cod_puja,
														num_rendimiento rendimiento,
														max(num_descuento) porcentaje,
														fec_hora_puja fecha_hora 
													FROM sis_pujas_operaciones_privadas 
                                                    WHERE
															cod_venta = pNum_Venta and 	
															num_rendimiento = (SELECT min(num_rendimiento) FROM sis_pujas_operaciones_privadas WHERE cod_venta = pNum_Venta)
													GROUP BY cod_puja_operacion ,fec_hora_puja ) tbl
										WHERE 	tbl.porcentaje = (Select max(num_descuento) FROM sis_pujas_operaciones_privadas WHERE cod_venta = pNum_Venta and 	
												num_rendimiento = (SELECT min(num_rendimiento) FROM sis_pujas_operaciones_privadas WHERE cod_venta = pNum_Venta))));
		RETURN select_var;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_PUJA_PROPIA_INVERSIONISTA` (`pNum_Venta` INT, `pIdentificacion` VARCHAR(15), `pTipo` CHAR(1)) RETURNS DECIMAL(10,1) NO SQL
BEGIN
 DECLARE v_mejor_puja decimal(10,1);
 DECLARE v_puja_vendedor decimal(10,2);
 
 SET v_puja_vendedor = (select num_rendimiento from sis_operaciones_cooperativas where num_operacion = pNum_Venta);
 
	IF (pTipo = 'V') THEN
 SET v_mejor_puja = (Select IFNULL(min(num_rendimiento),v_puja_vendedor)  cod_puja 
						FROM sis_pujas_operaciones 
						WHERE cod_venta = pNum_Venta and 	
						REPLACE(cod_vendedor,'-','') = REPLACE(pIdentificacion,'-',''));
 ELSE
  SET v_mejor_puja = (Select IFNULL(min(PJ.num_rendimiento),v_puja_vendedor)  cod_puja 
						FROM sis_pujas_operaciones 	PJ
                        INNER JOIN sis_operaciones_cooperativas O ON O.num_operacion = PJ.cod_venta
						WHERE PJ.cod_venta = pNum_Venta and 	
						REPLACE(PJ.cod_comprador,'-','') = REPLACE(pIdentificacion,'-',''));
	END IF;
        
 RETURN v_mejor_puja;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_PUJA_PROPIA_INVERSIONISTA_P` (`pNum_Venta` INT, `pIdentificacion` VARCHAR(15), `pTipo` CHAR(1)) RETURNS DECIMAL(10,1) NO SQL
BEGIN
 DECLARE v_mejor_puja decimal(10,1);
 DECLARE v_puja_vendedor decimal(10,2);
 
 SET v_puja_vendedor = (select num_rendimiento from sis_operaciones_pymes where num_operacion = pNum_Venta);
 
	IF (pTipo = 'V') THEN
 SET v_mejor_puja = (Select IFNULL(min(num_rendimiento),v_puja_vendedor)  cod_puja 
						FROM sis_pujas_operaciones_privadas 
						WHERE cod_venta = pNum_Venta and 	
						REPLACE(cod_vendedor,'-','') = REPLACE(pIdentificacion,'-',''));
 ELSE
  SET v_mejor_puja = (Select IFNULL(min(PJ.num_rendimiento),v_puja_vendedor)  cod_puja 
						FROM sis_pujas_operaciones_privadas PJ
                        INNER JOIN sis_operaciones_pymes O ON O.num_operacion = PJ.cod_venta
						WHERE PJ.cod_venta = pNum_Venta and 	
						REPLACE(PJ.cod_comprador,'-','') = REPLACE(pIdentificacion,'-',''));
	END IF;
        
 RETURN v_mejor_puja;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_PUJA_RENDIMEINTO_MENOR` (`pNum_Venta` INT) RETURNS INT(15) NO SQL
    COMMENT 'Funcion que retorn el numero de operacion d puja c/rend menor'
BEGIN
DECLARE select_var numeric(15);
SET select_var = (select min(cod_puja_operacion) FROM sis_pujas_operaciones
where cod_venta = pNum_Venta
and num_rendimiento = (SELECT min(num_rendimiento) FROM sis_pujas_operaciones WHERE cod_venta = pNum_Venta));
RETURN select_var;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_SALDO_CAPTACION` (`pNumOperacion` INT(11), `pCodigoEmision` INT(11)) RETURNS DECIMAL(20,2) NO SQL
BEGIN
DECLARE resultado DECIMAL(20,2);
  
	SET resultado = (SELECT O.mon_transado - ifnull((SELECT SUM(mon_calce) FROM sis_calces_captaciones WHERE num_operacion = pNumOperacion and cod_emision = pCodigoEmision) ,0) as saldo_emision 
					FROM sis_operaciones_cooperativas O
						INNER JOIN sis_emisiones E ON O.cod_emision = E.cod_emision 
						WHERE E.cod_emision = pCodigoEmision
						and O.num_operacion = pNumOperacion);
					
                
	RETURN resultado;

END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_SALDO_CAPTACION_PRIVADA` (`pNumOperacion` INT(11), `pCodigoEmision` INT(11)) RETURNS DECIMAL(20,2) NO SQL
BEGIN
DECLARE resultado DECIMAL(20,2);
  
	SET resultado = (SELECT O.mon_transado - ifnull((SELECT SUM(mon_calce) FROM sis_calces_captaciones_pymes WHERE num_operacion = pNumOperacion and cod_emision = pCodigoEmision) ,0) as saldo_emision 
					FROM sis_operaciones_pymes O
						INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision 
						WHERE E.cod_emision = pCodigoEmision
						and O.num_operacion = pNumOperacion);
					
                
	RETURN resultado;

END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_SALDO_TITULO` (`pCodigoEmision` INT(11)) RETURNS DECIMAL(20,2) NO SQL
BEGIN
DECLARE resultado DECIMAL(20,2);
  
    SET resultado = (SELECT E.mon_facial - ifnull((SELECT SUM(mon_calce) FROM sis_calces_captaciones WHERE cod_emision = pCodigoEmision) ,0) as saldo_emision 
					FROM sis_emisiones E WHERE E.cod_emision = pCodigoEmision );
   
	RETURN resultado;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_SALDO_TITULO_PRIVADO` (`pCodigoEmision` INT(11)) RETURNS DECIMAL(20,2) NO SQL
BEGIN
DECLARE resultado DECIMAL(20,2);
  
    SET resultado = (SELECT E.mon_facial - ifnull((SELECT SUM(mon_calce) FROM sis_calces_captaciones_pymes WHERE cod_emision = pCodigoEmision) ,0) as saldo_emision 
					FROM sis_emisiones_privadas E WHERE E.cod_emision = pCodigoEmision );
   
	RETURN resultado;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_SIGUIENTE_DIA_HABIL` (`pFechaOrigen` DATE) RETURNS DATE BEGIN
  DECLARE ctrl BOOLEAN default true;
  DECLARE FechaHabil DATE;
  DECLARE feriado INT default 0;
  DECLARE fin_de_semana INT default 0;
  DECLARE n INT default 1;
  
  WHILE ctrl = true DO
 
 SET feriado = (select DIA_FERIADO(DATE_ADD(pFechaOrigen, INTERVAL n DAY))); 
 
 SET fin_de_semana = (select FIN_DE_SEMANA(DATE_ADD(pFechaOrigen, INTERVAL n DAY))); 
   
   IF (fin_de_semana = 1 or feriado = 1) THEN  
		SET n = n + 1;       
		SET ctrl = true;      
		SET FechaHabil = (SELECT DATE_ADD(pFechaOrigen, INTERVAL n DAY));
   ELSE   
		SET ctrl = FALSE;    
		SET FechaHabil = (SELECT DATE_ADD(pFechaOrigen, INTERVAL n DAY));
   END IF;
 
    
  END WHILE;
   
RETURN FechaHabil;

END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `OBTENER_SIG_OPERACION_GRAFICAR` () RETURNS INT(5) BEGIN
  DECLARE vParametro int(5);
  DECLARE vSig_oper int(5);
  DECLARE vCod_Orden int(5);
  DECLARE vMax_Orden int(5);

		  SET vParametro = (SELECT val_parametro FROM sis_parametros where cod_parametro = 'SIS029');
		  
		  SET vCod_Orden = (SELECT cod_grafico from grf_orden_dashboard_factoring where num_operacion = vParametro);
		  SET vMax_Orden = (SELECT MAX(cod_grafico) from grf_orden_dashboard_factoring);
		  
			  IF (vCod_Orden + 1 > vMax_Orden) then
				SET vCod_Orden = 1;
					ELSE
				SET vCod_Orden = vCod_Orden +1;
				END IF;
			
		  
		  SET vSig_oper = (SELECT num_operacion from grf_orden_dashboard_factoring where cod_grafico = vCod_Orden );
		  
		  UPDATE grf_orden_dashboard_factoring
		  SET ind_actividad = 'N' 
		  where num_operacion = vParametro;
		  
		  UPDATE grf_orden_dashboard_factoring
		  SET ind_actividad = 'S' 
		  where num_operacion = vSig_oper;
		  
		  update sis_parametros
		  set val_parametro = vSig_oper
		  where cod_parametro = 'SIS029';
          
     
    
RETURN vSig_oper;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `PREPARA_HTML_CONTRATO` (`CED_CLIENTE` VARCHAR(50), `NUM_OPERACION` VARCHAR(50)) RETURNS VARCHAR(8000) CHARSET latin1 NO SQL
    COMMENT 'funcion utilizada en la generacion de contratos de cesion'
BEGIN
	DECLARE vResultado VARCHAR(8000);
	DECLARE v_dat_seccion INT(5);
    DECLARE v_dat_texto_fijo_seccion VARCHAR(3000);
    DECLARE v_dat_cod_variable VARCHAR(50);
	DECLARE v_dat_valor_variable VARCHAR(1000);
    
	DECLARE v_ctrl_seccion INT(5) DEFAULT 0;
    declare v_ctrl_texto VARCHAR(8000) DEFAULT '.';
    declare v_ctrl_texto_2 VARCHAR(8000) DEFAULT '';
-- Variable para controlar el fin del bucle
  DECLARE fin INTEGER DEFAULT 0;

-- El SELECT que vamos a ejecutar
  DECLARE contrato_cursor CURSOR FOR 
    SELECT S.cod_seccion_contrato, S.des_texto_fijo_seccion , 
			CASE WHEN V.cod_variable IS NULL OR V.cod_variable = '' THEN  '???????' ELSE V.cod_variable END cod_variable,
			CASE WHEN V.cod_variable IS NULL THEN '???????' ELSE DESCIFRAR_VARIABLE(S.cod_seccion_contrato, V.cod_variable, CED_CLIENTE, NUM_OPERACION)  END dat_valor_variable
	FROM sis_secciones_contratos S
		LEFT OUTER JOIN sis_variables_secciones V ON V.cod_seccion = S.cod_seccion_contrato and V.cod_contrato = S.cod_tipo_contrato
        ORDER BY S.num_ordenamiento_secion;

-- Condición de salida
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin=1;

  OPEN contrato_cursor;
  contrato_data: LOOP
    FETCH contrato_cursor INTO v_dat_seccion,v_dat_texto_fijo_seccion, v_dat_cod_variable, v_dat_valor_variable;
    IF fin = 1 THEN
       LEAVE contrato_data;
    END IF;
 
	  IF v_ctrl_seccion <> v_dat_seccion THEN    
		 SET v_ctrl_texto = REPLACE(v_dat_texto_fijo_seccion,v_dat_cod_variable,v_dat_valor_variable);
         SET v_ctrl_texto_2 = CONCAT(v_ctrl_texto_2,'<p>',v_ctrl_texto);
         SET v_ctrl_seccion = v_dat_seccion;
         INSERT INTO tmp_partes_contrato (des_seccion_completa,cod_seccion,num_operacion,num_identificacion) VALUES (v_ctrl_texto,v_dat_seccion,NUM_OPERACION,CED_CLIENTE);
	 ELSE
		
		SET v_ctrl_texto =  REPLACE(v_ctrl_texto,v_dat_cod_variable,v_dat_valor_variable);
        UPDATE `tmp_partes_contrato` SET des_seccion_completa = v_ctrl_texto WHERE cod_seccion = v_dat_seccion AND num_identificacion = CED_CLIENTE and num_operacion = NUM_OPERACION;
     
	 END IF; 
  
 
  END LOOP contrato_data;

  CLOSE contrato_cursor;
 
SET vResultado = v_ctrl_texto_2;
 
RETURN vResultado;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `PREPARA_HTML_FACTURA_ESTANDAR` (`CED_CLIENTE` VARCHAR(50), `NUM_OPERACION` VARCHAR(50), `FRACCIONES` INT(1)) RETURNS VARCHAR(8000) CHARSET latin1 BEGIN
	DECLARE vResultado VARCHAR(8000);
	DECLARE v_dat_seccion INT(5);
    DECLARE v_dat_texto_fijo_seccion VARCHAR(3000);
    DECLARE v_dat_cod_variable VARCHAR(50);
	DECLARE v_dat_valor_variable VARCHAR(1000);
    
	DECLARE v_ctrl_seccion INT(5) DEFAULT 0;
    declare v_ctrl_texto VARCHAR(8000) DEFAULT '.';
    declare v_ctrl_texto_2 VARCHAR(8000) DEFAULT '';
-- Variable para controlar el fin del bucle
  DECLARE fin INTEGER DEFAULT 0;

-- El SELECT que vamos a ejecutar
  DECLARE contrato_cursor CURSOR FOR 
    SELECT S.cod_seccion_contrato, S.des_texto_fijo_seccion , 
			CASE WHEN V.cod_variable IS NULL OR V.cod_variable = '' THEN  '???????' ELSE V.cod_variable END cod_variable,
			CASE WHEN V.cod_variable IS NULL THEN '???????' ELSE DESCIFRAR_VARIABLE_FACTURA_ESTANDAR(S.cod_seccion_contrato, V.cod_variable, CED_CLIENTE, NUM_OPERACION)  END dat_valor_variable
	FROM sis_secciones_contratos S
		LEFT OUTER JOIN sis_variables_secciones V ON V.cod_seccion = S.cod_seccion_contrato and V.cod_contrato = S.cod_tipo_contrato
        WHERE V.cod_contrato = 3
        ORDER BY S.num_ordenamiento_secion;

-- Condición de salida
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin=1;

  OPEN contrato_cursor;
  contrato_data: LOOP
    FETCH contrato_cursor INTO v_dat_seccion,v_dat_texto_fijo_seccion, v_dat_cod_variable, v_dat_valor_variable;
    IF fin = 1 THEN
       LEAVE contrato_data;
    END IF;
 
	  IF v_ctrl_seccion <> v_dat_seccion THEN    
		 SET v_ctrl_texto = REPLACE(v_dat_texto_fijo_seccion,v_dat_cod_variable,v_dat_valor_variable);
         SET v_ctrl_texto_2 = CONCAT(v_ctrl_texto_2,'<p>',v_ctrl_texto);
         SET v_ctrl_seccion = v_dat_seccion;
         INSERT INTO tmp_partes_factura_estandar (des_seccion_completa,cod_seccion,num_operacion,num_identificacion) VALUES (v_ctrl_texto,v_dat_seccion,NUM_OPERACION,CED_CLIENTE);
	 ELSE
		
		SET v_ctrl_texto =  REPLACE(v_ctrl_texto,v_dat_cod_variable,v_dat_valor_variable);
        UPDATE `tmp_partes_factura_estandar` SET des_seccion_completa = v_ctrl_texto WHERE cod_seccion = v_dat_seccion AND num_identificacion = CED_CLIENTE and num_operacion = NUM_OPERACION;
     
	 END IF; 
  
 
  END LOOP contrato_data;

  CLOSE contrato_cursor;
 
SET vResultado = v_ctrl_texto_2;
 
RETURN vResultado;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `PREPARA_HTML_LETRA_CAMBIO` (`CED_CLIENTE` VARCHAR(50), `NUM_OPERACION` VARCHAR(50)) RETURNS VARCHAR(8000) CHARSET latin1 BEGIN
	DECLARE vResultado VARCHAR(8000);
	DECLARE v_dat_seccion INT(5);
    DECLARE v_dat_texto_fijo_seccion VARCHAR(3000);
    DECLARE v_dat_cod_variable VARCHAR(50);
	DECLARE v_dat_valor_variable VARCHAR(1000);
    
	DECLARE v_ctrl_seccion INT(5) DEFAULT 0;
    declare v_ctrl_texto VARCHAR(8000) DEFAULT '.';
    declare v_ctrl_texto_2 VARCHAR(8000) DEFAULT '';
-- Variable para controlar el fin del bucle
  DECLARE fin INTEGER DEFAULT 0;

-- El SELECT que vamos a ejecutar
  DECLARE contrato_cursor CURSOR FOR 
    SELECT S.cod_seccion_contrato, S.des_texto_fijo_seccion , 
			CASE WHEN V.cod_variable IS NULL OR V.cod_variable = '' THEN  '???????' ELSE V.cod_variable END cod_variable,
			CASE WHEN V.cod_variable IS NULL THEN '???????' ELSE DESCIFRAR_VARIABLE_LETRA_CAMBIO(S.cod_seccion_contrato, V.cod_variable, CED_CLIENTE, NUM_OPERACION)  END dat_valor_variable
	FROM sis_secciones_contratos S
		LEFT OUTER JOIN sis_variables_secciones V ON V.cod_seccion = S.cod_seccion_contrato and V.cod_contrato = S.cod_tipo_contrato
        WHERE V.cod_contrato = 2
        ORDER BY S.num_ordenamiento_secion;

-- Condición de salida
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin=1;

  OPEN contrato_cursor;
  contrato_data: LOOP
    FETCH contrato_cursor INTO v_dat_seccion,v_dat_texto_fijo_seccion, v_dat_cod_variable, v_dat_valor_variable;
    IF fin = 1 THEN
       LEAVE contrato_data;
    END IF;
 
	  IF v_ctrl_seccion <> v_dat_seccion THEN    
		 SET v_ctrl_texto = REPLACE(v_dat_texto_fijo_seccion,v_dat_cod_variable,v_dat_valor_variable);
         SET v_ctrl_texto_2 = CONCAT(v_ctrl_texto_2,'<p>',v_ctrl_texto);
         SET v_ctrl_seccion = v_dat_seccion;
         INSERT INTO tmp_partes_letra_cambio (des_seccion_completa,cod_seccion,num_operacion,num_identificacion) VALUES (v_ctrl_texto,v_dat_seccion,NUM_OPERACION,CED_CLIENTE);
	 ELSE
		
		SET v_ctrl_texto =  REPLACE(v_ctrl_texto,v_dat_cod_variable,v_dat_valor_variable);
        UPDATE `tmp_partes_letra_cambio` SET des_seccion_completa = v_ctrl_texto WHERE cod_seccion = v_dat_seccion AND num_identificacion = CED_CLIENTE and num_operacion = NUM_OPERACION;
     
	 END IF; 
  
 
  END LOOP contrato_data;

  CLOSE contrato_cursor;
 
SET vResultado = v_ctrl_texto_2;
 
RETURN vResultado;
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `TRAER_MONTO_LIQ_COMPRAS` (`MFL` DECIMAL(20,2), `RND` DECIMAL(20,2), `PJE` INT(3), `PZO` INT(5), `MDA` INT(3), `ID` VARCHAR(50), `TPO` INT(3), `LIQ` CHAR(1), `IND1` INT(3), `IND2` INT(3)) RETURNS DECIMAL(20,2) BEGIN
 DECLARE vResultado NUMERIC(20,2);
 DECLARE vTranzado NUMERIC(20,2);
 DECLARE vComision NUMERIC(20,2);
 
 
 		IF MDA <= 0 THEN
        RETURN 1;
        END IF;
        
        
        IF PZO <= 0 THEN
        RETURN 1;
        END IF;
        
        IF RND <= 0 THEN
        RETURN 1;
        END IF;
        
        IF MFL <= 0 THEN
        RETURN 1;
        END IF;
        
        IF PJE <= 0 THEN
        RETURN 1;
        END IF;
        
SET vComision = OBTENER_COMISION (MFL,RND,PJE,PZO,MDA,ID,TPO,LIQ,IND1,IND2);
        
SET vTranzado = TRAER_MONTO_TRANSADO(MFL,RND,PZO,PJE,MDA,LIQ,IND1,IND2);
        
SET vResultado = vTranzado + vComision;
  
  return vResultado;
  
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `TRAER_MONTO_LIQ_VENTAS` (`MFL` DECIMAL(20,2), `RND` DECIMAL(20,2), `PJE` INT(3), `PZO` INT(5), `MDA` INT(3), `ID` VARCHAR(50), `TPO` INT(3), `LIQ` CHAR(1), `IND1` INT(3), `IND2` INT(3)) RETURNS DECIMAL(20,2) BEGIN
 DECLARE vResultado NUMERIC(20,2);
 DECLARE vTranzado NUMERIC(20,2);
 DECLARE vComision NUMERIC(20,2);
 
 
 		IF MDA <= 0 THEN
        RETURN 1;
        END IF;
        
        
        IF PZO <= 0 THEN
        RETURN 1;
        END IF;
        
        IF RND <= 0 THEN
        RETURN 1;
        END IF;
        
        IF MFL <= 0 THEN
        RETURN 1;
        END IF;
        
        IF PJE <= 0 THEN
        RETURN 1;
        END IF;
        
SET vComision = OBTENER_COMISION (MFL,RND,PJE,PZO,MDA,ID,TPO,LIQ,IND1,IND2);
        
SET vTranzado = TRAER_MONTO_TRANSADO(MFL,RND,PZO,PJE,MDA,LIQ,IND1,IND2);
        
SET vResultado = vTranzado - vComision;
  
  return vResultado;
  
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `TRAER_MONTO_TOTAL_FACTORING` (`ID` VARCHAR(50)) RETURNS DECIMAL(20,2) BEGIN
 DECLARE vResultado decimal(20,2);
 DECLARE total_colones decimal(20,2);
 DECLARE total_liq_colones decimal(20,2);
 DECLARE total_liq_dolares decimal(20,2);
 DECLARE total_dolares decimal(20,2);
 DECLARE tipo_cambio decimal(20,2);
 
 
 		IF ID <= 0 THEN
        RETURN 1;
        END IF;
        
        SET ID = (SELECT REPLACE(ID,'-',''));
        
SET tipo_cambio = (SELECT  `num_valor` FROM `sis_tipo_cambio_monedas` 
					WHERE fec_tipo_cambio =(SELECT MAX(fec_tipo_cambio) FROM sis_tipo_cambio_monedas WHERE cod_moneda = 2 and cod_fuente = 4 ) 	
						and cod_moneda = 2	and cod_fuente = 4);
                        
SET total_colones = (select 
						case when cod_comprador = ID then sum(mon_liquidacion_comprador) else sum(mon_liquidacion_vendedor) end total_colones
						from sis_operaciones
						where (cod_comprador = ID  or cod_vendedor = ID)
						and cod_estado = 6
						and cod_tipo_moneda = 1 and ind_operacion_liquidada = "N");
 

SET total_liq_colones = (select 
						case when cod_comprador = ID then sum(mon_liquidacion_comprador) else sum(mon_liquidacion_vendedor) end total_liq_colones
						from sis_operaciones
						where (cod_comprador = ID  or cod_vendedor = ID)
						and cod_estado = 6
						and cod_tipo_moneda = 2 and ind_operacion_liquidada = "S");

SET total_liq_dolares = (select  
						case when cod_comprador = ID then sum(mon_liquidacion_comprador * mon_tipo_cambio_liquidacion ) else sum(mon_liquidacion_vendedor * mon_tipo_cambio_liquidacion) end total_liq_dolares
						from sis_operaciones
						where (cod_comprador = ID  or cod_vendedor = ID)
						and cod_estado = 6
						and cod_tipo_moneda = 1 and ind_operacion_liquidada = "S");

SET total_dolares = (select  
						case when cod_comprador = ID 
						then ifnull(sum(mon_liquidacion_comprador * tipo_cambio),0)
						else ifnull(sum(mon_liquidacion_vendedor * tipo_cambio),0)
						end total_dolares
						from sis_operaciones
						where (cod_comprador = ID  or cod_vendedor = ID)
						and cod_estado = 6
						and cod_tipo_moneda = 2 and ind_operacion_liquidada = "N");

        
SET vResultado = ifnull(total_colones,0) + ifnull(total_liq_colones,0) + ifnull(total_liq_dolares,0) + ifnull(total_dolares,0);
  
  return vResultado;
  
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `TRAER_MONTO_TRANSADO` (`MN` DECIMAL(20,2), `RND` DECIMAL(3,1), `DV` DECIMAL(5), `PJE` DECIMAL(3), `MDA` INT(1), `LIQ` CHAR(1), `IND1` INT(3), `IND2` INT(3)) RETURNS DECIMAL(20,2) BEGIN
 DECLARE vResultado NUMERIC(20,2);
 DECLARE vTOTAL NUMERIC(20,2);
 DECLARE vTipoCambio DECIMAL(10,2);
 DECLARE vParametro DECIMAL(5,2);
 
 SET vParametro  = (SELECT val_parametro AS MargenProteccion  FROM sis_parametros WHERE cod_parametro =  'SIS025');
 
 SET vTipoCambio =	(SELECT  `num_valor` 
						FROM `sis_tipo_cambio_monedas` 
							WHERE fec_tipo_cambio =(SELECT MAX(fec_tipo_cambio) FROM sis_tipo_cambio_monedas WHERE cod_moneda = 2 and cod_fuente = 4 ) 
								and cod_moneda = 2
								and cod_fuente = 4);

-- Evita la divio entre cero
        IF DV <= 0 THEN
        RETURN 1;
        END IF;
        
-- Evita la divio entre cero
        IF RND <= 0 THEN
        RETURN 1;
        END IF;
        
-- Evita la divio entre cero
        IF MN <= 0 THEN
        RETURN 1;
        END IF;
        
-- Evita la divio entre cero
        IF PJE <= 0 THEN
        RETURN 1;
        END IF;
        
-- FORMULA DEL monto transado 
CASE
    WHEN ((MDA = 1) AND (LIQ= 'N')) THEN SET vTOTAL = MN * (PJE / 100);  /*devuelve colones*/
    WHEN ((MDA = 2) AND (LIQ= 'S')) THEN SET vTOTAL = (MN * (vTipoCambio * vParametro)) * (PJE / 100);	/*devuelve colones dolarizados*/
    WHEN ((MDA = 2) AND (LIQ= 'N')) THEN SET vTOTAL = MN * (PJE / 100);	/*devuelve dolares*/
    WHEN ((MDA = 1) AND (LIQ= 'S')) THEN SET vTOTAL = (MN / (vTipoCambio / vParametro)) * (PJE / 100);	/*devuelve dolares colonizados*/
    ELSE SET vTOTAL = 1;
END CASE;
 
		 
        SET vResultado = vTOTAL - (vTOTAL * (RND /100) / 365 * DV);
        
         RETURN vResultado;
        
        
END$$

CREATE DEFINER=`masterzon`@`localhost` FUNCTION `VALIDAR_SESION_WEB` (`pToken` VARCHAR(100), `pUsuario` VARCHAR(50)) RETURNS TINYINT(1) BEGIN
  DECLARE vTokenDB varchar(100);
  DECLARE vFechaHoraDB DATETIME;
  DECLARE vResultado tinyint(1);
  
  SET vTokenDB = (SELECT cod_token from sis_usuarios where cod_usuario = pUsuario);
  SET vFechaHoraDB = (SELECT fec_hora_fin_sesion from sis_usuarios where cod_usuario = pUsuario);
  
  IF (pToken = vTokenDB AND vFechaHoraDB > NOW() ) THEN
 SET vResultado = true;
  else
 SET vResultado = false;
  END IF;
    
RETURN vResultado;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `grf_orden_dashboard_factoring`
--

CREATE TABLE `grf_orden_dashboard_factoring` (
  `num_operacion` int(5) NOT NULL,
  `ind_actividad` char(1) DEFAULT 'N' COMMENT 'Indica cualq operacion debe desplegarse en el dashboard (S=Activo / N=Inactivo)',
  `cod_grafico` int(3) NOT NULL COMMENT 'Indica el codigo del grafico a desplegar '
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='Ordena las operaciones que aparecen en el grafico de pujas de factoring';

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `password_resets`
--

INSERT INTO `password_resets` (`email`, `token`, `created_at`) VALUES
('gporras@masterzon.com', '88a38d1a4f8e9fc3f87eab8b9feb0c2c430e1643ad46940d57736730e3868b3f', '2016-08-23 09:23:06'),
('jrivas@brokerscapitalcr.com', 'f18327dd4913433e303b18d6da9fbdb5bacacb0259049d6aef4720a3dfcb29a0', '2016-11-19 00:31:22'),
('yhoffman@lexincorp.com', '81819ce2d5c549edcc56156955026b17e1c9bf52ae8511cfcbc85075115f96b8', '2016-11-24 00:11:19'),
('gerson78@gmail.com', '124dc00a9d97404aad94032ee364737dd83a514525cd0a4426fd9f79caf15a96', '2017-02-21 02:08:29'),
('enerplanet@gmail.com', '51be7612a1e5ce946fd235ba62dd1745e0b939c87a270f2d3bb4b0cd808e0587', '2017-05-10 23:01:06'),
('grethel53@gmail.com', '96f40458cb2d85848b08c5513f20565bf18ee0e755b13a7c296bbbdcce542c2b', '2017-02-20 09:22:58');

-- --------------------------------------------------------

--
-- Table structure for table `sis_bitacora_accesos`
--

CREATE TABLE `sis_bitacora_accesos` (
  `fec_hora_acceso` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cod_usuario` varchar(50) NOT NULL,
  `num_direccion_ip` varchar(50) NOT NULL,
  `des_navegador` varchar(50) NOT NULL,
  `des_version_navegador` varchar(50) NOT NULL,
  `des_sistema_operativo` varchar(50) NOT NULL,
  `des_archivo` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla que almacena los accesos a marterzon';

--
-- Dumping data for table `sis_bitacora_accesos`
--

INSERT INTO `sis_bitacora_accesos` (`fec_hora_acceso`, `cod_usuario`, `num_direccion_ip`, `des_navegador`, `des_version_navegador`, `des_sistema_operativo`, `des_archivo`) VALUES
('2018-11-08 03:30:57', 'jrivas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:31:47', 'jrivas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:33:51', 'jrivas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:34:23', 'jrivas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:38:54', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:39:14', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:39:25', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:41:29', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:45:00', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:45:10', 'erojas ', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:50:57', 'cbartels', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:51:44', 'cbartels', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:55:34', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:55:39', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:56:01', 'jrivas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:56:13', 'jrivas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 03:57:31', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 04:01:37', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 04:02:16', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 06:08:37', 'erojas', '201.191.195.216', 'CHROME', '69.0.3497.100', 'LINUX', 'validar_usuario.php'),
('2018-11-08 06:08:38', 'erojas', '201.191.195.216', 'CHROME', '69.0.3497.100', 'LINUX', 'validar_usuario.php'),
('2018-11-08 07:20:06', 'rvillalobos', '201.191.0.192', 'CHROME', '56.0.2924.87', 'LINUX', 'validar_usuario.php'),
('2018-11-08 14:49:32', 'erojas', '201.191.198.88', 'CHROME', '69.0.3497.100', 'LINUX', 'validar_usuario.php'),
('2018-11-08 16:46:02', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:14:04', 'jrivas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:24:10', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:34:02', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:34:13', 'fulate', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:34:24', 'fulate', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:34:58', 'gguillen', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:36:15', 'fulate', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:37:51', 'erojas', '186.176.28.236', 'FIREFOX', '59.0', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:39:13', 'erojas ', '186.176.28.236', 'FIREFOX', '59.0', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:39:45', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:40:41', 'erojas ', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 17:49:14', 'erojas ', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 18:17:51', 'erojas', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 18:20:58', 'gguillen', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 18:24:37', 'erojas ', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 18:51:19', 'erojas ', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 18:51:28', 'erojas ', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 18:51:31', 'erojas ', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 18:57:14', 'erojas ', '186.176.28.236', 'CHROME', '70.0.3538.77', 'WIN', 'validar_usuario.php'),
('2018-11-08 20:50:20', 'cbartels', '92.110.194.56', 'CHROME', '70.0.3538.77', 'MAC', 'validar_usuario.php'),
('2018-11-08 20:53:46', 'cbartels', '92.110.194.56', 'CHROME', '70.0.3538.77', 'MAC', 'validar_usuario.php'),
('2018-11-08 20:57:15', 'cbartels', '92.110.194.56', 'CHROME', '70.0.3538.77', 'MAC', 'validar_usuario.php');

-- --------------------------------------------------------

--
-- Table structure for table `sis_bitacora_eventos`
--

CREATE TABLE `sis_bitacora_eventos` (
  `num_consecutivo` int(11) NOT NULL,
  `fec_hora_evento` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cod_usuario` varchar(50) NOT NULL,
  `des_archivo` varchar(50) NOT NULL,
  `des_proceso` varchar(100) NOT NULL,
  `des_query` varchar(2000) NOT NULL,
  `des_definicion` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla que almacea los eventos realizados por los usuario en Masterzon.com';

--
-- Dumping data for table `sis_bitacora_eventos`
--

INSERT INTO `sis_bitacora_eventos` (`num_consecutivo`, `fec_hora_evento`, `cod_usuario`, `des_archivo`, `des_proceso`, `des_query`, `des_definicion`) VALUES
(1, '2018-11-08 03:30:57', 'jrivas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$OHLUsz4UeR.nQd7j8tDK/uRtL/nvl7LtIj6ObXsy3QnZDr6.UGBEe, cod_token = $2y$10$OHLUsz4UeR.nQd7j8tDK/uRtL/nvl7LtIj6ObXsy3QnZDr6.UGBEe, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = jrivas', 'Paso 1, Se encripta la clave y token'),
(2, '2018-11-08 03:30:57', 'jrivas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(3, '2018-11-08 03:30:57', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(4, '2018-11-08 03:30:57', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(5, '2018-11-08 03:30:57', 'jrivas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(6, '2018-11-08 03:31:47', 'jrivas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$zZCB50tRXoXERjV5HGOBlO/gdpxN5WnJQhOjQzNVJQcJy.gM0sNye, cod_token = $2y$10$zZCB50tRXoXERjV5HGOBlO/gdpxN5WnJQhOjQzNVJQcJy.gM0sNye, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = jrivas', 'Paso 1, Se encripta la clave y token'),
(7, '2018-11-08 03:31:47', 'jrivas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(8, '2018-11-08 03:31:47', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(9, '2018-11-08 03:31:47', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(10, '2018-11-08 03:31:47', 'jrivas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(11, '2018-11-08 03:33:51', 'jrivas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$j4sAZ9htMUhkLFsve8Tn5.GNW3ZLjC.5wKgfzU.vDL9yyKmVag4VK, cod_token = $2y$10$j4sAZ9htMUhkLFsve8Tn5.GNW3ZLjC.5wKgfzU.vDL9yyKmVag4VK, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = jrivas', 'Paso 1, Se encripta la clave y token'),
(12, '2018-11-08 03:33:51', 'jrivas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(13, '2018-11-08 03:33:51', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(14, '2018-11-08 03:33:51', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(15, '2018-11-08 03:33:51', 'jrivas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(16, '2018-11-08 03:34:23', 'jrivas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$LQ5.RO2Z/czFlFq27Vd.v.yig9nkOo/0aqXbi5.zjrGnJ8Dt4KWYW, cod_token = $2y$10$LQ5.RO2Z/czFlFq27Vd.v.yig9nkOo/0aqXbi5.zjrGnJ8Dt4KWYW, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = jrivas', 'Paso 1, Se encripta la clave y token'),
(17, '2018-11-08 03:34:23', 'jrivas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(18, '2018-11-08 03:34:23', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(19, '2018-11-08 03:34:23', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(20, '2018-11-08 03:34:23', 'jrivas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(21, '2018-11-08 03:34:23', 'jrivas', '/primario/validar_usuario.php', 'Insert de nueva captacion', '1/140000/11', 'Paso 6, Lectura de datos formulario'),
(22, '2018-11-08 03:34:23', 'jrivas', '/primario/validar_usuario.php', 'Consulta emision y titulo', 'SELECT E.fec_vencimiento,E.mon_facial,I.cod_moneda_instrumento,\r\n			DATEDIFF(E.fec_vencimiento,OBTENER_FECHA_LIQUIDACION()) as plazo\r\n			FROM sis_emisiones_privadas E\r\n			INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n			where E.cod_emision = 1', 'Paso 7, Consulta datos p/crear captacion'),
(23, '2018-11-08 03:34:23', 'jrivas', '/primario/validar_usuario.php', 'Inserta captacion', 'INSERT INTO `sis_operaciones_pymes`\r\n			(`cod_emision`,`cod_tipo_factura`,`cod_vendedor`,`ind_tipo_cliente`,`cod_tipo_moneda`,`cod_tipo_plazo`,`cod_estado`,\r\n			`mon_facial`,`mon_transado`,`num_rendimiento`,`num_descuento`,`fec_emision`,`fec_estimada_pago`,\r\n			`fec_liquidacion`,`mon_liquidacion_comprador`,`mon_comision_comprador`,`mon_liquidacion_vendedor`,\r\n			`mon_comision_vendedor`,`mon_tipo_cambio_liquidacion`,`num_parametro_liquidacion`,`fec_vencimiento`,\r\n			`des_ruta_certificado`,`fec_registro`,`usr_registro`)\r\n			VALUES\r\n			(1,1,3101677940,P,2,365 ,1,\r\n			140000.00,140000,11,100,NOW(),2019-11-09,\r\n			DATE_ADD(now(), INTERVAL 1 DAY),0,0,0,\r\n			0,1,0,2019-11-09,				\r\n			n/r,now(),jrivas)', 'Paso 8, Creacion de captacion'),
(24, '2018-11-08 03:38:54', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$EZSF4qGpdV5KRgImGNk75.yHPbujA/1Boil4qJV9s/DSOlpjd9.v2, cod_token = $2y$10$EZSF4qGpdV5KRgImGNk75.yHPbujA/1Boil4qJV9s/DSOlpjd9.v2, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(25, '2018-11-08 03:38:54', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(26, '2018-11-08 03:38:54', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(27, '2018-11-08 03:38:54', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(28, '2018-11-08 03:38:54', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(29, '2018-11-08 03:39:14', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$/I5zzJNqPG2mWJCyxAM8E.O6nb25yZlXdoe4SWmAVIzGmsmkGZRfu, cod_token = $2y$10$/I5zzJNqPG2mWJCyxAM8E.O6nb25yZlXdoe4SWmAVIzGmsmkGZRfu, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(30, '2018-11-08 03:39:14', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(31, '2018-11-08 03:39:14', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(32, '2018-11-08 03:39:14', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(33, '2018-11-08 03:39:14', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(34, '2018-11-08 03:39:25', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$tFmlRuyla1XKKX.nxsZgCeD3dRQAaGgnIWKD/ZmZEu3A4URFrXugm, cod_token = $2y$10$tFmlRuyla1XKKX.nxsZgCeD3dRQAaGgnIWKD/ZmZEu3A4URFrXugm, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(35, '2018-11-08 03:39:25', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(36, '2018-11-08 03:39:25', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(37, '2018-11-08 03:39:25', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(38, '2018-11-08 03:39:25', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(39, '2018-11-08 03:39:32', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 1, Obtiene la diferencia en horas entre Oregon USA, y CR'),
(40, '2018-11-08 03:39:32', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 2, Obtiene la compania a partir del usuario'),
(41, '2018-11-08 03:39:32', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 6, Obtiene los datos iniciales.'),
(42, '2018-11-08 03:39:32', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(11.0,0) as num_rendimiento,\r\n				format(( ( (1 + 11.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 109260511\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 7, Obtiene los datos de la operacion.'),
(43, '2018-11-08 03:39:32', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(11.0,0) as num_rendimiento,\r\n				format(( ( (1 + 11.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 109260511\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 8, Obtiene la mejor puja'),
(44, '2018-11-08 03:41:29', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$GfC2W5syb78Bb9uxnVTDceCB4mOEZMZgX/HdvR57WnC5oEKA4/yDq, cod_token = $2y$10$GfC2W5syb78Bb9uxnVTDceCB4mOEZMZgX/HdvR57WnC5oEKA4/yDq, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(45, '2018-11-08 03:41:29', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(46, '2018-11-08 03:41:29', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(47, '2018-11-08 03:41:29', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(48, '2018-11-08 03:41:29', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(49, '2018-11-08 03:41:33', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 1, Obtiene la diferencia en horas entre Oregon USA, y CR'),
(50, '2018-11-08 03:41:33', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 2, Obtiene la compania a partir del usuario'),
(51, '2018-11-08 03:41:33', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 6, Obtiene los datos iniciales.'),
(52, '2018-11-08 03:41:33', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(11.0,0) as num_rendimiento,\r\n				format(( ( (1 + 11.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 109260511\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 7, Obtiene los datos de la operacion.'),
(53, '2018-11-08 03:41:33', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(11.0,0) as num_rendimiento,\r\n				format(( ( (1 + 11.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 109260511\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 8, Obtiene la mejor puja'),
(54, '2018-11-08 03:45:00', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$mhPR3Vpd5w21bmV8rxjni.TiPhGVNEVHv/5HTuPRAiI4Pnqr/gUca, cod_token = $2y$10$mhPR3Vpd5w21bmV8rxjni.TiPhGVNEVHv/5HTuPRAiI4Pnqr/gUca, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(55, '2018-11-08 03:45:00', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(56, '2018-11-08 03:45:00', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(57, '2018-11-08 03:45:00', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(58, '2018-11-08 03:45:00', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(59, '2018-11-08 03:45:04', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 1, Obtiene la diferencia en horas entre Oregon USA, y CR'),
(60, '2018-11-08 03:45:04', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 2, Obtiene la compania a partir del usuario'),
(61, '2018-11-08 03:45:04', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 6, Obtiene los datos iniciales.'),
(62, '2018-11-08 03:45:04', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(11.0,0) as num_rendimiento,\r\n				format(( ( (1 + 11.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 109260511\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 7, Obtiene los datos de la operacion.'),
(63, '2018-11-08 03:45:04', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,11.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,109260511,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(11.0,0) as num_rendimiento,\r\n				format(( ( (1 + 11.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 109260511\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 8, Obtiene la mejor puja'),
(64, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT OBTENER_DIFERENCIA_HORARIO_USA() as Diff_USA', 'Paso 1, Se obtiene la diferencia de horas con USA'),
(65, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT REPLACE(cod_compania,-,) as compania, des_nombre, des_apellido1 from sis_usuarios where cod_usuario = erojas ', 'Paso 2, obtiene la informacion de la empresa a partir del usuario'),
(66, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT OBTENER_FECHA_LIQUIDACION() as fec_liq,DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liq_formato', 'Paso 3, Se obtiene la fecha de liquidacion'),
(67, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT REPLACE(O.cod_vendedor,-,) AS cod_vendedor, \n					O.cod_emision, \n					O.mon_facial, \n					O.cod_tipo_plazo,\n					O.cod_tipo_moneda,	\n					O.ind_operacion_liquidada, \n					O.num_rendimiento \n				FROM sis_operaciones_pymes O \n				WHERE num_operacion = 1 ', 'Paso 4, Se obtiene los datos de la operacion.'),
(68, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'INSERT INTO sis_pujas_operaciones_privadas_hist VALUES (0,1,REPLACE(109260511,-,),11.0,100,140000.00,4,3101677940,11.0, erojas , DATE_ADD(now(),INTERVAL 2 HOUR)	)', 'Paso 5, Inserta la puja en la tabla hitorica de pujas.'),
(69, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT count(cod_puja_operacion) Cantidad FROM sis_pujas_operaciones_privadas WHERE REPLACE(cod_comprador,-,) = REPLACE(109260511,-,) and cod_venta = 1 and REPLACE(cod_vendedor,-,) = REPLACE(3101677940,-,)', 'Paso 6, Consulta si inversionista ya hizo pujas a esta operacion'),
(70, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'INSERT INTO sis_pujas_operaciones_privadas VALUES (0,109260511,DATE_ADD(now(),INTERVAL 2 HOUR),5,3101677940,1,11.0,100,140000.00 ,erojas )', 'Paso 7, Inversionista ingresa nueva puja.'),
(71, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT min(P.cod_puja_operacion) numero, OBTENER_SALDO_CAPTACION_PRIVADA(1, O.cod_emision) as saldo, OBTENER_SALDO_TITULO_PRIVADO(O.cod_emision) as SaldoTitulo \n		 FROM sis_operaciones_pymes O \n		 INNER JOIN sis_pujas_operaciones_privadas P ON O.num_operacion = P.cod_venta\n		 WHERE num_operacion = 1 and P.num_rendimiento = O.num_rendimiento and P.num_descuento = O.num_descuento', 'Paso 8, Se consultan las pujas para saber si hay almenos una que calce con el numero de operacion'),
(72, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Inversionista calza la operacion', 'SELECT min(P.cod_puja_operacion) numero, OBTENER_SALDO_CAPTACION_PRIVADA(1, O.cod_emision) as saldo, OBTENER_SALDO_TITULO_PRIVADO(O.cod_emision) as SaldoTitulo \n		 FROM sis_operaciones_pymes O \n		 INNER JOIN sis_pujas_operaciones_privadas P ON O.num_operacion = P.cod_venta\n		 WHERE num_operacion = 1 and P.num_rendimiento = O.num_rendimiento and P.num_descuento = O.num_descuento', 'Paso 9, Confirmacion de calce'),
(73, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Inversionista calza operacion.', 'UPDATE sis_operaciones_pymes SET cod_estado = 5	WHERE num_operacion = 1 and cod_estado in (1,4,12)', 'Paso 10, Se cambia el estado de la operacion a Calzada'),
(74, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'INSERT INTO sis_calces_captaciones_pymes (cod_emision, num_operacion, cod_comprador, num_rendimiento, mon_calce, fec_hora_calce)\n		VALUES (1, 1, 109260511, 11.0, 140000.00, now())', 'Paso 11, Inserta nuevo calce'),
(75, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Se elimina la puja de calce', 'DELETE FROM sis_pujas_operaciones_privadas WHERE cod_venta = 1 and cod_comprador = 109260511 and cod_vendedor = 3101677940', 'Paso 12, Borrar puja de calce automaticamente'),
(76, '2018-11-08 01:45:09', '', 'actualizacion_emision_privada.php', '(Inv calza) Construccion de notificacion calce', 'SELECT 	\n		E.cod_emision,\n		O.num_operacion,\n		J.des_nick_name as nick_cooperativa,\n		format(O.mon_transado,2) as mon_transado,\n		format(E.mon_facial,2) as mon_facial,\n		E.cod_instrumento,\n		P.des_periodicidad,\n		M.des_tipo_moneda,\n		format(C.mon_calce,2) as mon_calce,\n		I.des_nick_name as nick_inversionista,\n		format(O.num_rendimiento,1) as num_rendimiento,\n		C.fec_hora_calce,\n		format(OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision),2) as Saldo_titulo,\n		format(OBTENER_SALDO_CAPTACION_PRIVADA(O.num_operacion,E.cod_emision),2) as Saldo_Captacion,\n		O.cod_vendedor,						\n		DATE_FORMAT(O.fec_liquidacion,%d %b %Y) as fec_liquidacion,\n		DATE_FORMAT(O.fec_vencimiento,%d %b %Y) as fec_vencimiento,\n		format(( ( (1 + C.num_rendimiento / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\n		format((C.mon_calce + OBTENER_COMISION (C.mon_calce,C.num_rendimiento,O.num_descuento,O.cod_tipo_plazo,T.cod_moneda_instrumento,C.cod_comprador,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ),2) as NetoPagar,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS018) as c_dol_ATA,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS021) as c_col_ATA,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS019) as cta_dol_ATA,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS022) as cta_col_ATA,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS023) as iban_col_ATA,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS020) as iban_dol_ATA\n																\n		FROM sis_operaciones_pymes O \n		INNER JOIN sis_emisiones_privadas E ON E.cod_emision = O.cod_emision\n		INNER JOIN sis_catalogo_instrumentos T ON T.cod_instrumento = E.cod_instrumento\n		INNER JOIN sis_calces_captaciones_pymes C ON C.cod_emision = E.cod_emision and C.num_operacion = O.num_operacion and C.num_rendimiento = O.num_rendimiento\n		INNER JOIN sis_catalogo_juridicos J ON ', 'Consulta datos de operacion'),
(77, '2018-11-08 03:45:09', 'erojas ', '/primario/actualizacion_c_privada.php', 'Ln 272 Notificacion para clientes 109260511 operacion # 1', 'enviar_notificaciones($con,$usr_registro,$compania,$idemp)', 'notificacion sin adjunto, enviada correctamente'),
(78, '2018-11-08 03:45:10', 'erojas ', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$2V1M7PQ1pVkoJAqxakLVsu6XPe05sJ8kWIHcIk/LuRgEt5u1ssh/O, cod_token = $2y$10$2V1M7PQ1pVkoJAqxakLVsu6XPe05sJ8kWIHcIk/LuRgEt5u1ssh/O, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas ', 'Paso 1, Se encripta la clave y token'),
(79, '2018-11-08 03:45:10', 'erojas ', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(80, '2018-11-08 03:45:10', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(81, '2018-11-08 03:45:10', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(82, '2018-11-08 03:45:10', 'erojas ', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(83, '2018-11-08 03:50:57', 'cbartels', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$Vz5E0kSnkBKTfBT13rAbGO2U75iIIca2BnP6IHR9QV2mvsZz68sfW, cod_token = $2y$10$Vz5E0kSnkBKTfBT13rAbGO2U75iIIca2BnP6IHR9QV2mvsZz68sfW, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = cbartels', 'Paso 1, Se encripta la clave y token'),
(84, '2018-11-08 03:50:57', 'cbartels', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 152800006724 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(85, '2018-11-08 03:50:57', 'cbartels', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 152800006724 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(86, '2018-11-08 03:50:57', 'cbartels', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(87, '2018-11-08 03:50:57', 'cbartels', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(88, '2018-11-08 03:51:44', 'cbartels', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$n4ggBf5WkpT2Xh3SxbBZ2.J3WVSh/Qr.jvXZE1TjKbUrI9qhoJzka, cod_token = $2y$10$n4ggBf5WkpT2Xh3SxbBZ2.J3WVSh/Qr.jvXZE1TjKbUrI9qhoJzka, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = cbartels', 'Paso 1, Se encripta la clave y token'),
(89, '2018-11-08 03:51:44', 'cbartels', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 152800006724 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(90, '2018-11-08 03:51:44', 'cbartels', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 152800006724 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(91, '2018-11-08 03:51:44', 'cbartels', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(92, '2018-11-08 03:51:44', 'cbartels', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(93, '2018-11-08 03:55:34', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$W4SCWmRi5IAS5GXDlREl0OsBNKEeSAruMp9d925jhIJzxznh3qagq, cod_token = $2y$10$W4SCWmRi5IAS5GXDlREl0OsBNKEeSAruMp9d925jhIJzxznh3qagq, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(94, '2018-11-08 03:55:34', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(95, '2018-11-08 03:55:34', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(96, '2018-11-08 03:55:34', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(97, '2018-11-08 03:55:34', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(98, '2018-11-08 03:55:39', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$kZO9Bm7c9QtQf96IpGY6J.9rhh/zxIJq6Yjpr/hke7.o9A9tLfSO., cod_token = $2y$10$kZO9Bm7c9QtQf96IpGY6J.9rhh/zxIJq6Yjpr/hke7.o9A9tLfSO., fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(99, '2018-11-08 03:55:39', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(100, '2018-11-08 03:55:39', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(101, '2018-11-08 03:55:39', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(102, '2018-11-08 03:55:39', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(103, '2018-11-08 03:56:01', 'jrivas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$CYiog2Wm2yCACD3kWNv17uWM9/LcJrGNCvrtIBI4vrqJ9Y4fQu84C, cod_token = $2y$10$CYiog2Wm2yCACD3kWNv17uWM9/LcJrGNCvrtIBI4vrqJ9Y4fQu84C, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = jrivas', 'Paso 1, Se encripta la clave y token'),
(104, '2018-11-08 03:56:01', 'jrivas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(105, '2018-11-08 03:56:01', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(106, '2018-11-08 03:56:01', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(107, '2018-11-08 03:56:01', 'jrivas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(108, '2018-11-08 03:56:10', 'jrivas', '/primario/calculos_privadas.php', 'Proveedor calcula liquidacion', '1 / 10 / 140000.00', 'Paso 3, Obtiene los datos iniciales.');
INSERT INTO `sis_bitacora_eventos` (`num_consecutivo`, `fec_hora_evento`, `cod_usuario`, `des_archivo`, `des_proceso`, `des_query`, `des_definicion`) VALUES
(109, '2018-11-08 03:56:10', 'jrivas', '/primario/calculos_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,10,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,O.cod_vendedor,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				E.mon_facial,\r\n				DATE_FORMAT(O.fec_liquidacion,%d %b %Y) as fec_liquidacion,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(10,0) as num_rendimiento,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				OBTENER_SALDO_CAPTACION_PRIVADA(O.num_operacion,E.cod_emision) as mon_saldo_captacion,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)\r\n				AND O.ind_tipo_cliente = P', 'Paso 4, Obtiene los datos de la operacion.'),
(110, '2018-11-08 03:56:10', 'jrivas', '/primario/calculos_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,10,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,O.cod_vendedor,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				E.mon_facial,\r\n				DATE_FORMAT(O.fec_liquidacion,%d %b %Y) as fec_liquidacion,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(10,0) as num_rendimiento,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				OBTENER_SALDO_CAPTACION_PRIVADA(O.num_operacion,E.cod_emision) as mon_saldo_captacion,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)\r\n				AND O.ind_tipo_cliente = P', 'Paso 5, Obtiene la mejor puja'),
(111, '2018-11-08 03:56:12', 'jrivas', '/primario/actualizacion_emision_privada.php', 'Diferencia horario USA', 'SELECT OBTENER_DIFERENCIA_HORARIO_USA() as Diff_USA', 'Paso 1, Se obtiene la diferencia de horas con USA'),
(112, '2018-11-08 03:56:12', 'jrivas', '/primario/actualizacion_emision_privada.php', 'Se obtienen los datos del usaurio', 'SELECT REPLACE(cod_compania,-,) as compania, des_nombre, des_apellido1 from sis_usuarios where cod_usuario = jrivas', 'Paso 2, Obtiene la informacion de la empresa a partir del usuario'),
(113, '2018-11-08 03:56:12', 'jrivas', '/primario/actualizacion_emision_privada.php', 'Actualizar monto de la captacion y minimo de titulo', 'UPDATE `sis_operaciones_pymes` SET num_rendimiento = 10, `mon_transado` = 140000.00 WHERE `num_operacion` = 1', 'Paso 3, Coopertiva modifica minimo de emision '),
(114, '2018-11-08 03:56:12', 'jrivas', '/primario/actualizacion_emision_privada.php', 'Consulta que confirma si hay un calce.', 'SELECT 	\r\n                                min(P.cod_puja_operacion) numero,\r\n                                OBTENER_SALDO_TITULO_PRIVADO(O.cod_emision) as saldo,\r\n								OBTENER_SALDO_CAPTACION_PRIVADA(O.num_operacion, E.cod_emision) as saldo_captacion,\r\n                                P.cod_vendedor,\r\n                                P.cod_comprador,\r\n                                O.cod_emision,\r\n                                P.mon_transado\r\n                                FROM sis_operaciones_pymes O \r\n								INNER JOIN sis_emisiones_privadas E On E.cod_emision = O.cod_emision\r\n                                INNER JOIN sis_pujas_operaciones_privadas P ON O.num_operacion = P.cod_venta and P.cod_venta = 1 \r\n                                WHERE P.num_rendimiento = 10\r\n                                and P.mon_transado <= O.mon_transado', 'Paso 4, Select a sis_pujas_operaciones.'),
(115, '2018-11-08 03:56:12', 'jrivas', '/primario/actualizacion_emision_privada.php', '', '', ''),
(116, '2018-11-08 03:56:13', 'jrivas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$M2FMgd50jSOVl61D631q9eTNo0crx6qSO7gGx4wkPRh7dogMMuBuG, cod_token = $2y$10$M2FMgd50jSOVl61D631q9eTNo0crx6qSO7gGx4wkPRh7dogMMuBuG, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = jrivas', 'Paso 1, Se encripta la clave y token'),
(117, '2018-11-08 03:56:13', 'jrivas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(118, '2018-11-08 03:56:13', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(119, '2018-11-08 03:56:13', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(120, '2018-11-08 03:56:13', 'jrivas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(121, '2018-11-08 03:57:31', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$DAALu9qHwicT461/92223uySqm54ASbonjotkGlBQN3HNOYpA/cQK, cod_token = $2y$10$DAALu9qHwicT461/92223uySqm54ASbonjotkGlBQN3HNOYpA/cQK, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(122, '2018-11-08 03:57:31', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(123, '2018-11-08 03:57:31', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(124, '2018-11-08 03:57:31', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(125, '2018-11-08 03:57:31', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(126, '2018-11-08 03:58:56', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 1, Obtiene la diferencia en horas entre Oregon USA, y CR'),
(127, '2018-11-08 03:58:56', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 2, Obtiene la compania a partir del usuario'),
(128, '2018-11-08 03:58:56', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 6, Obtiene los datos iniciales.'),
(129, '2018-11-08 03:58:56', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(10.0,0) as num_rendimiento,\r\n				format(( ( (1 + 10.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 152800006724\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 7, Obtiene los datos de la operacion.'),
(130, '2018-11-08 03:58:56', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(10.0,0) as num_rendimiento,\r\n				format(( ( (1 + 10.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 152800006724\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 8, Obtiene la mejor puja'),
(131, '2018-11-08 04:01:37', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$Ugr2TjsKNvPJ8aXOtqSyCuQ5JE8QM/itjNBisQzgaHhWsQGly7svy, cod_token = $2y$10$Ugr2TjsKNvPJ8aXOtqSyCuQ5JE8QM/itjNBisQzgaHhWsQGly7svy, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(132, '2018-11-08 04:01:37', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(133, '2018-11-08 04:01:37', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(134, '2018-11-08 04:01:37', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(135, '2018-11-08 04:01:37', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(136, '2018-11-08 04:01:41', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 1, Obtiene la diferencia en horas entre Oregon USA, y CR'),
(137, '2018-11-08 04:01:41', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 2, Obtiene la compania a partir del usuario'),
(138, '2018-11-08 04:01:42', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 6, Obtiene los datos iniciales.'),
(139, '2018-11-08 04:01:42', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(10.0,0) as num_rendimiento,\r\n				format(( ( (1 + 10.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 152800006724\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 7, Obtiene los datos de la operacion.'),
(140, '2018-11-08 04:01:42', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(10.0,0) as num_rendimiento,\r\n				format(( ( (1 + 10.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 152800006724\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 8, Obtiene la mejor puja'),
(141, '2018-11-08 04:02:16', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$0wVFPkcndfOG6grKFtgrsu7XyS1Kq6Tpok/X08xp7SRO0B04Ky6Pi, cod_token = $2y$10$0wVFPkcndfOG6grKFtgrsu7XyS1Kq6Tpok/X08xp7SRO0B04Ky6Pi, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(142, '2018-11-08 04:02:16', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(143, '2018-11-08 04:02:16', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(144, '2018-11-08 04:02:16', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(145, '2018-11-08 04:02:16', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(146, '2018-11-08 06:08:37', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$P2spB97mS7yxLOuKkDTWeeXA6P.tbtRnPZN9lUKF7G.3D7QymT1He, cod_token = $2y$10$P2spB97mS7yxLOuKkDTWeeXA6P.tbtRnPZN9lUKF7G.3D7QymT1He, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(147, '2018-11-08 06:08:37', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(148, '2018-11-08 06:08:37', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(149, '2018-11-08 06:08:37', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(150, '2018-11-08 06:08:37', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(151, '2018-11-08 06:08:38', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$IxmFqzKWjR/mGSGJdwrMW.Ha5B6nGQTlXKQXhNMfDmP35GA.xirAK, cod_token = $2y$10$IxmFqzKWjR/mGSGJdwrMW.Ha5B6nGQTlXKQXhNMfDmP35GA.xirAK, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(152, '2018-11-08 06:08:38', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(153, '2018-11-08 06:08:38', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(154, '2018-11-08 06:08:38', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(155, '2018-11-08 06:08:38', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(156, '2018-11-08 06:08:52', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 1, Obtiene la diferencia en horas entre Oregon USA, y CR'),
(157, '2018-11-08 06:08:52', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 2, Obtiene la compania a partir del usuario'),
(158, '2018-11-08 06:08:52', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 6, Obtiene los datos iniciales.'),
(159, '2018-11-08 06:08:52', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(10.0,0) as num_rendimiento,\r\n				format(( ( (1 + 10.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 152800006724\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 7, Obtiene los datos de la operacion.'),
(160, '2018-11-08 06:08:52', 'erojas ', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(10.0,0) as num_rendimiento,\r\n				format(( ( (1 + 10.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 152800006724\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 8, Obtiene la mejor puja'),
(161, '2018-11-08 07:20:06', 'rvillalobos', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$lI5Esdp8BPbi15sJrLwywO/YqbNQuVC6/LGoCpu8xfZ/sFycQ5wA2, cod_token = $2y$10$lI5Esdp8BPbi15sJrLwywO/YqbNQuVC6/LGoCpu8xfZ/sFycQ5wA2, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = rvillalobos', 'Paso 1, Se encripta la clave y token'),
(162, '2018-11-08 07:20:06', 'rvillalobos', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 401600419 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(163, '2018-11-08 07:20:06', 'rvillalobos', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 401600419 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(164, '2018-11-08 07:20:06', 'rvillalobos', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(165, '2018-11-08 07:20:06', 'rvillalobos', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(166, '2018-11-08 14:49:32', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$8IPO3nEbIxESU0xMF0wus.gr2S1MZ24t.O84gUaBzy2rGWIMBpMOu, cod_token = $2y$10$8IPO3nEbIxESU0xMF0wus.gr2S1MZ24t.O84gUaBzy2rGWIMBpMOu, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(167, '2018-11-08 14:49:32', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(168, '2018-11-08 14:49:32', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(169, '2018-11-08 14:49:32', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(170, '2018-11-08 14:49:32', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(171, '2018-11-08 16:46:02', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$RLb7ufRqFH.lczQ8ySMQve3P44UX36fhmP/qCWoIvmbH5.YnT.Kbu, cod_token = $2y$10$RLb7ufRqFH.lczQ8ySMQve3P44UX36fhmP/qCWoIvmbH5.YnT.Kbu, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(172, '2018-11-08 16:46:02', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(173, '2018-11-08 16:46:02', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(174, '2018-11-08 16:46:02', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(175, '2018-11-08 16:46:02', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(176, '2018-11-08 17:14:04', 'jrivas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$wpHweuPrvW4mU6NdntsV0ezE3XhPEMboF..r6gAqkS//UpBq5YqC., cod_token = $2y$10$wpHweuPrvW4mU6NdntsV0ezE3XhPEMboF..r6gAqkS//UpBq5YqC., fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = jrivas', 'Paso 1, Se encripta la clave y token'),
(177, '2018-11-08 17:14:04', 'jrivas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(178, '2018-11-08 17:14:04', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 206440727 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(179, '2018-11-08 17:14:04', 'jrivas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(180, '2018-11-08 17:14:04', 'jrivas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(181, '2018-11-08 17:24:10', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$Y3znxYwmvJ6zmUYgKZAEMeZd21mPzBeMAbuwOr0VR9h7.9UQZZ0U., cod_token = $2y$10$Y3znxYwmvJ6zmUYgKZAEMeZd21mPzBeMAbuwOr0VR9h7.9UQZZ0U., fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(182, '2018-11-08 17:24:10', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(183, '2018-11-08 17:24:10', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(184, '2018-11-08 17:24:10', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(185, '2018-11-08 17:24:10', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(186, '2018-11-08 17:34:02', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$04nmZkKJfIqsdajuqHcmNOdAd6j9vf700LKqSobwGNZoVO.9h0CQq, cod_token = $2y$10$04nmZkKJfIqsdajuqHcmNOdAd6j9vf700LKqSobwGNZoVO.9h0CQq, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(187, '2018-11-08 17:34:02', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(188, '2018-11-08 17:34:02', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(189, '2018-11-08 17:34:02', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(190, '2018-11-08 17:34:02', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(191, '2018-11-08 17:34:13', 'fulate', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$zNB1.Tp1qr.4M4JYJHH6y.UL.E3h2jz1sSeowKsfkI4i0b3CEm4Bm, cod_token = $2y$10$zNB1.Tp1qr.4M4JYJHH6y.UL.E3h2jz1sSeowKsfkI4i0b3CEm4Bm, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = fulate', 'Paso 1, Se encripta la clave y token'),
(192, '2018-11-08 17:34:13', 'fulate', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 401610041 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(193, '2018-11-08 17:34:13', 'fulate', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 401610041 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(194, '2018-11-08 17:34:13', 'fulate', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(195, '2018-11-08 17:34:13', 'fulate', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(196, '2018-11-08 17:34:24', 'fulate', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$524ScrhRZGnQYuJiAFWwzeTv3r1My2NW5rFma9n0ashHqvQF5FDU6, cod_token = $2y$10$524ScrhRZGnQYuJiAFWwzeTv3r1My2NW5rFma9n0ashHqvQF5FDU6, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = fulate', 'Paso 1, Se encripta la clave y token'),
(197, '2018-11-08 17:34:24', 'fulate', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 401610041 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(198, '2018-11-08 17:34:24', 'fulate', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 401610041 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(199, '2018-11-08 17:34:24', 'fulate', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(200, '2018-11-08 17:34:24', 'fulate', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(201, '2018-11-08 17:34:58', 'gguillen', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$LbX39h2C2CGTECAHk2xYR.elEyJSX/Pb8EdU.BM1pyFYNcjSr8ZgG, cod_token = $2y$10$LbX39h2C2CGTECAHk2xYR.elEyJSX/Pb8EdU.BM1pyFYNcjSr8ZgG, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = gguillen', 'Paso 1, Se encripta la clave y token'),
(202, '2018-11-08 17:34:58', 'gguillen', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 110000867 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(203, '2018-11-08 17:34:58', 'gguillen', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 110000867 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(204, '2018-11-08 17:34:58', 'gguillen', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(205, '2018-11-08 17:34:58', 'gguillen', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(206, '2018-11-08 17:36:15', 'fulate', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$0fZGkysGCG9AfHlHKW.VzOCXFFjSs2FEo/4QnGISelmmMnXrB5CKG, cod_token = $2y$10$0fZGkysGCG9AfHlHKW.VzOCXFFjSs2FEo/4QnGISelmmMnXrB5CKG, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = fulate', 'Paso 1, Se encripta la clave y token'),
(207, '2018-11-08 17:36:15', 'fulate', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 401610041 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(208, '2018-11-08 17:36:15', 'fulate', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 401610041 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(209, '2018-11-08 17:36:15', 'fulate', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(210, '2018-11-08 17:36:15', 'fulate', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(211, '2018-11-08 17:36:23', 'fulate', '/primario/estadoCta.php', 'Ingreso al estado de cuenta ', 'SELECT OBTENER_DIFERENCIA_HORARIO_USA() as Diff_USA', 'Paso 1, obtiene la diferencia de horario con USA.'),
(212, '2018-11-08 17:36:23', 'fulate', '/primario/estadoCta.php', 'Ingreso al estado de cuenta ', 'SELECT  `num_valor` FROM `sis_tipo_cambio_monedas` WHERE fec_tipo_cambio =(SELECT MAX(fec_tipo_cambio) FROM sis_tipo_cambio_monedas WHERE cod_moneda = 2 and cod_fuente = 4 ) and cod_moneda = 2 and cod_fuente = 4', 'Paso 2, obtiene el tipo de cambio de la fuente Masterzon'),
(213, '2018-11-08 17:36:23', 'fulate', '/primario/estadoCta.php', 'Ingreso y carga de controles del estado de cuenta', 'SELECT \r\n						S.cod_compania as compania, \r\n						S.des_nombre, \r\n						S.des_apellido1 , \r\n						J.des_razon_social, \r\n						J.des_logo_cliente, \r\n						J.des_direccion_contacto,\r\n						J.des_telefono_contacto,\r\n						J.des_correo_contacto,\r\n						M.des_tipo_membresia,\r\n						S.ind_alertas_nuevos,\r\n						S.ind_alertas_cambios,\r\n						S.ind_alertas_sms_cambios,\r\n						S.ind_cierre_bloqueo_operaciones,\r\n						S.cod_perfil,\r\n						S.mon_minimo_filtro_facial,\r\n						S.num_maximo_filtro_plazo,\r\n						S.ind_filtro_sector,\r\n						S.ind_filtro_moneda,\r\n						S.ind_filtro_propias,\r\n						S.ind_filtro_tipoNegocio\r\n					FROM sis_usuarios S \r\n						INNER JOIN sis_catalogo_juridicos J ON REPLACE(J.num_identificacion,-,) = REPLACE(S.cod_compania,-,) \r\n						INNER JOIN sis_catalogo_membresias M ON M.cod_tipo_membresia = J.cod_tipo_membresia\r\n					WHERE cod_usuario = fulate ', 'Paso 3, Carga perfil del cliente.'),
(214, '2018-11-08 17:36:23', 'fulate', '/primario/estadoCta.php', 'Ingreso totales por negocio del estado de cuenta', 'SELECT cod_usuario, ind_alertas_nuevos, ind_alertas_cambios, ind_alertas_sms_cambios, ind_cierre_bloqueo_operaciones, mon_minimo_filtro_facial,ind_filtro_sector, ind_filtro_moneda, num_maximo_filtro_plazo ,ind_filtro_propias,ind_filtro_tipoNegocio\r\n		FROM sis_usuarios	where cod_usuario = fulate', 'Paso 5, Carga las cofiguraciones del perfil del cliente'),
(215, '2018-11-08 17:37:51', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$22xRcK4WiBQWD5EuV9Li3OZNEKdWlql5CJr9aPIuIT2.G2.Pphj3m, cod_token = $2y$10$22xRcK4WiBQWD5EuV9Li3OZNEKdWlql5CJr9aPIuIT2.G2.Pphj3m, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token');
INSERT INTO `sis_bitacora_eventos` (`num_consecutivo`, `fec_hora_evento`, `cod_usuario`, `des_archivo`, `des_proceso`, `des_query`, `des_definicion`) VALUES
(216, '2018-11-08 17:37:51', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(217, '2018-11-08 17:37:51', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(218, '2018-11-08 17:37:51', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(219, '2018-11-08 17:37:51', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(220, '2018-11-08 17:39:13', 'erojas ', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$.d9uCNx7GgG9Z4/oss6cNOvBt5zFsXiFci6CWBmi7wIB8yd8AIOeq, cod_token = $2y$10$.d9uCNx7GgG9Z4/oss6cNOvBt5zFsXiFci6CWBmi7wIB8yd8AIOeq, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas ', 'Paso 1, Se encripta la clave y token'),
(221, '2018-11-08 17:39:13', 'erojas ', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(222, '2018-11-08 17:39:13', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(223, '2018-11-08 17:39:13', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(224, '2018-11-08 17:39:13', 'erojas ', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(225, '2018-11-08 17:39:45', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$h8YuR8RQ2R1qjE4/uWUbgeo1JBc9AJwudP80VLxzC/979CPOnnKke, cod_token = $2y$10$h8YuR8RQ2R1qjE4/uWUbgeo1JBc9AJwudP80VLxzC/979CPOnnKke, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(226, '2018-11-08 17:39:45', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(227, '2018-11-08 17:39:45', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(228, '2018-11-08 17:39:45', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(229, '2018-11-08 17:39:45', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(230, '2018-11-08 17:40:41', 'erojas ', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$Onycu9fT/jBHuEw2aqQWLusG64oCULnmZXx4lGMkxyHqlmnSa4Fh6, cod_token = $2y$10$Onycu9fT/jBHuEw2aqQWLusG64oCULnmZXx4lGMkxyHqlmnSa4Fh6, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas ', 'Paso 1, Se encripta la clave y token'),
(231, '2018-11-08 17:40:41', 'erojas ', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(232, '2018-11-08 17:40:41', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(233, '2018-11-08 17:40:41', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(234, '2018-11-08 17:40:41', 'erojas ', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(235, '2018-11-08 17:49:14', 'erojas ', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$2InaLwCLYm.dsQ9GC.KqiOSbSABqJS5sYxERHOi.XybdI/5TqGvCO, cod_token = $2y$10$2InaLwCLYm.dsQ9GC.KqiOSbSABqJS5sYxERHOi.XybdI/5TqGvCO, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas ', 'Paso 1, Se encripta la clave y token'),
(236, '2018-11-08 17:49:14', 'erojas ', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(237, '2018-11-08 17:49:14', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(238, '2018-11-08 17:49:14', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(239, '2018-11-08 17:49:14', 'erojas ', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(240, '2018-11-08 18:17:51', 'erojas', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$gdCdqfcqyb/PzkunhOKJQuk33X4eyxaBZhKsLkm37PN9fckmgu7r6, cod_token = $2y$10$gdCdqfcqyb/PzkunhOKJQuk33X4eyxaBZhKsLkm37PN9fckmgu7r6, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas', 'Paso 1, Se encripta la clave y token'),
(241, '2018-11-08 18:17:51', 'erojas', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(242, '2018-11-08 18:17:51', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(243, '2018-11-08 18:17:51', 'erojas', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(244, '2018-11-08 18:17:51', 'erojas', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(245, '2018-11-08 18:20:58', 'gguillen', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$e4wwLCuxqAstjGjFwuEuF.Ez98YkdpyU7dxts/iZg.7SvAMrglS/G, cod_token = $2y$10$e4wwLCuxqAstjGjFwuEuF.Ez98YkdpyU7dxts/iZg.7SvAMrglS/G, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = gguillen', 'Paso 1, Se encripta la clave y token'),
(246, '2018-11-08 18:20:58', 'gguillen', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 110000867 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(247, '2018-11-08 18:20:58', 'gguillen', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 110000867 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(248, '2018-11-08 18:20:58', 'gguillen', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(249, '2018-11-08 18:20:58', 'gguillen', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(250, '2018-11-08 18:24:37', 'erojas ', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$DZscBbKdAhsnqbnmjgmcYOMfD/n7bejvzfTN7hxoF76Lvx/L2mFtm, cod_token = $2y$10$DZscBbKdAhsnqbnmjgmcYOMfD/n7bejvzfTN7hxoF76Lvx/L2mFtm, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas ', 'Paso 1, Se encripta la clave y token'),
(251, '2018-11-08 18:24:37', 'erojas ', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(252, '2018-11-08 18:24:37', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(253, '2018-11-08 18:24:37', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(254, '2018-11-08 18:24:37', 'erojas ', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(255, '2018-11-08 18:51:19', 'erojas ', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$BnLtwtsMmZlHGX04hdKZ6Ok4P7eSmvFspJgNtD6QwwEV34OzEjgre, cod_token = $2y$10$BnLtwtsMmZlHGX04hdKZ6Ok4P7eSmvFspJgNtD6QwwEV34OzEjgre, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas ', 'Paso 1, Se encripta la clave y token'),
(256, '2018-11-08 18:51:19', 'erojas ', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(257, '2018-11-08 18:51:19', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(258, '2018-11-08 18:51:19', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(259, '2018-11-08 18:51:19', 'erojas ', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(260, '2018-11-08 18:51:28', 'erojas ', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$ccOsE7QyPiiKfwiTEPTN3ejYfKhJ.eOaaqhV4tkSSzahCTWgxVUKG, cod_token = $2y$10$ccOsE7QyPiiKfwiTEPTN3ejYfKhJ.eOaaqhV4tkSSzahCTWgxVUKG, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas ', 'Paso 1, Se encripta la clave y token'),
(261, '2018-11-08 18:51:28', 'erojas ', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(262, '2018-11-08 18:51:28', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(263, '2018-11-08 18:51:28', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(264, '2018-11-08 18:51:28', 'erojas ', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(265, '2018-11-08 18:51:31', 'erojas ', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$tnkHW4hreryXXpwlcbX3fOpjAqQjuLgMbgb4NOUMxv.HSc9bhxQi2, cod_token = $2y$10$tnkHW4hreryXXpwlcbX3fOpjAqQjuLgMbgb4NOUMxv.HSc9bhxQi2, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas ', 'Paso 1, Se encripta la clave y token'),
(266, '2018-11-08 18:51:31', 'erojas ', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(267, '2018-11-08 18:51:31', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(268, '2018-11-08 18:51:31', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(269, '2018-11-08 18:51:31', 'erojas ', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(270, '2018-11-08 18:57:14', 'erojas ', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$nwhjxXJuMMXNXCBVlulZB.SfAYAgC9vF94zF99jcFwmm487dAR./y, cod_token = $2y$10$nwhjxXJuMMXNXCBVlulZB.SfAYAgC9vF94zF99jcFwmm487dAR./y, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = erojas ', 'Paso 1, Se encripta la clave y token'),
(271, '2018-11-08 18:57:14', 'erojas ', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(272, '2018-11-08 18:57:14', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 109260511 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(273, '2018-11-08 18:57:14', 'erojas ', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(274, '2018-11-08 18:57:14', 'erojas ', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(275, '2018-11-08 20:50:20', 'cbartels', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$wOa8UNpxQrlsPrPBUK9DTefucOcAHYsXPKcnauuO3n6SG3XRcT5DW, cod_token = $2y$10$wOa8UNpxQrlsPrPBUK9DTefucOcAHYsXPKcnauuO3n6SG3XRcT5DW, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = cbartels', 'Paso 1, Se encripta la clave y token'),
(276, '2018-11-08 20:50:20', 'cbartels', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 152800006724 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(277, '2018-11-08 20:50:20', 'cbartels', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 152800006724 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(278, '2018-11-08 20:50:20', 'cbartels', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(279, '2018-11-08 20:50:20', 'cbartels', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(280, '2018-11-08 20:53:46', 'cbartels', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$LJfhogO0kcTPup3o5dWK1Ox14VZqqFqQA289ap65PfmIKshmklOVa, cod_token = $2y$10$LJfhogO0kcTPup3o5dWK1Ox14VZqqFqQA289ap65PfmIKshmklOVa, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = cbartels', 'Paso 1, Se encripta la clave y token'),
(281, '2018-11-08 20:53:46', 'cbartels', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 152800006724 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(282, '2018-11-08 20:53:46', 'cbartels', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 152800006724 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(283, '2018-11-08 20:53:46', 'cbartels', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(284, '2018-11-08 20:53:46', 'cbartels', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas'),
(285, '2018-11-08 20:56:05', 'cbartels', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 1, Obtiene la diferencia en horas entre Oregon USA, y CR'),
(286, '2018-11-08 20:56:05', 'cbartels', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 2, Obtiene la compania a partir del usuario'),
(287, '2018-11-08 20:56:05', 'cbartels', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', '', 'Paso 6, Obtiene los datos iniciales.'),
(288, '2018-11-08 20:56:05', 'cbartels', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(10.0,0) as num_rendimiento,\r\n				format(( ( (1 + 10.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 152800006724\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 7, Obtiene los datos de la operacion.'),
(289, '2018-11-08 20:56:05', 'cbartels', '/primario/calculos_c_privadas.php', 'Proveedor calcula liquidacion', 'SELECT O.num_operacion,\r\n				OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) as mon_comision,\r\n				140000.00 as mon_transado,\r\n				(140000.00 + OBTENER_COMISION (140000.00,10.0,O.num_descuento,O.cod_tipo_plazo,I.cod_moneda_instrumento,152800006724,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ) as NetoPagar,\r\n				E.mon_facial,\r\n				E.cod_instrumento,\r\n				E.mon_minimo_negociacion,\r\n				IFNULL(10.0,0) as num_rendimiento,\r\n				format(( ( (1 + 10.0 / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\r\n				J.des_nick_name,\r\n				O.cod_tipo_plazo,\r\n				M.des_tipo_moneda,\r\n				OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision) as mon_saldo,\r\n				0 as mon_costo_neto,\r\n				O.cod_estado as estado,\r\n				I.cod_moneda_instrumento,\r\n				DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liquidacion\r\n				FROM sis_operaciones_pymes O\r\n				INNER JOIN sis_emisiones_privadas E ON O.cod_emision = E.cod_emision\r\n				INNER JOIN sis_catalogo_instrumentos I ON I.cod_instrumento = E.cod_instrumento\r\n				INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = I.cod_moneda_instrumento		\r\n				INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n				INNER JOIN sis_catalogo_juridicos JC ON JC.num_identificacion = 152800006724\r\n				INNER JOIN sis_catalogo_membresias ME ON ME.cod_tipo_membresia = JC.cod_tipo_membresia\r\n				WHERE O.num_operacion = 1\r\n				AND E.ind_estado in (R,P,B)', 'Paso 8, Obtiene la mejor puja'),
(290, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT OBTENER_DIFERENCIA_HORARIO_USA() as Diff_USA', 'Paso 1, Se obtiene la diferencia de horas con USA'),
(291, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT REPLACE(cod_compania,-,) as compania, des_nombre, des_apellido1 from sis_usuarios where cod_usuario = cbartels', 'Paso 2, obtiene la informacion de la empresa a partir del usuario'),
(292, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT OBTENER_FECHA_LIQUIDACION() as fec_liq,DATE_FORMAT(OBTENER_FECHA_LIQUIDACION(),%d %b %Y) as fec_liq_formato', 'Paso 3, Se obtiene la fecha de liquidacion'),
(293, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT REPLACE(O.cod_vendedor,-,) AS cod_vendedor, \n					O.cod_emision, \n					O.mon_facial, \n					O.cod_tipo_plazo,\n					O.cod_tipo_moneda,	\n					O.ind_operacion_liquidada, \n					O.num_rendimiento \n				FROM sis_operaciones_pymes O \n				WHERE num_operacion = 1 ', 'Paso 4, Se obtiene los datos de la operacion.'),
(294, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'INSERT INTO sis_pujas_operaciones_privadas_hist VALUES (0,1,REPLACE(152800006724,-,),10.0,100,140000.00,4,3101677940,10.0, cbartels, DATE_ADD(now(),INTERVAL 2 HOUR)	)', 'Paso 5, Inserta la puja en la tabla hitorica de pujas.'),
(295, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT count(cod_puja_operacion) Cantidad FROM sis_pujas_operaciones_privadas WHERE REPLACE(cod_comprador,-,) = REPLACE(152800006724,-,) and cod_venta = 1 and REPLACE(cod_vendedor,-,) = REPLACE(3101677940,-,)', 'Paso 6, Consulta si inversionista ya hizo pujas a esta operacion'),
(296, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'INSERT INTO sis_pujas_operaciones_privadas VALUES (0,152800006724,DATE_ADD(now(),INTERVAL 2 HOUR),5,3101677940,1,10.0,100,140000.00 ,cbartels)', 'Paso 7, Inversionista ingresa nueva puja.'),
(297, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'SELECT min(P.cod_puja_operacion) numero, OBTENER_SALDO_CAPTACION_PRIVADA(1, O.cod_emision) as saldo, OBTENER_SALDO_TITULO_PRIVADO(O.cod_emision) as SaldoTitulo \n		 FROM sis_operaciones_pymes O \n		 INNER JOIN sis_pujas_operaciones_privadas P ON O.num_operacion = P.cod_venta\n		 WHERE num_operacion = 1 and P.num_rendimiento = O.num_rendimiento and P.num_descuento = O.num_descuento', 'Paso 8, Se consultan las pujas para saber si hay almenos una que calce con el numero de operacion'),
(298, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Inversionista calza la operacion', 'SELECT min(P.cod_puja_operacion) numero, OBTENER_SALDO_CAPTACION_PRIVADA(1, O.cod_emision) as saldo, OBTENER_SALDO_TITULO_PRIVADO(O.cod_emision) as SaldoTitulo \n		 FROM sis_operaciones_pymes O \n		 INNER JOIN sis_pujas_operaciones_privadas P ON O.num_operacion = P.cod_venta\n		 WHERE num_operacion = 1 and P.num_rendimiento = O.num_rendimiento and P.num_descuento = O.num_descuento', 'Paso 9, Confirmacion de calce'),
(299, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Inversionista calza operacion.', 'UPDATE sis_operaciones_pymes SET cod_estado = 5	WHERE num_operacion = 1 and cod_estado in (1,4,12)', 'Paso 10, Se cambia el estado de la operacion a Calzada'),
(300, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Actualizacion de posicion inversionista', 'INSERT INTO sis_calces_captaciones_pymes (cod_emision, num_operacion, cod_comprador, num_rendimiento, mon_calce, fec_hora_calce)\n		VALUES (1, 1, 152800006724, 10.0, 140000.00, now())', 'Paso 11, Inserta nuevo calce'),
(301, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Se elimina la puja de calce', 'DELETE FROM sis_pujas_operaciones_privadas WHERE cod_venta = 1 and cod_comprador = 152800006724 and cod_vendedor = 3101677940', 'Paso 12, Borrar puja de calce automaticamente'),
(302, '2018-11-08 18:57:15', '', 'actualizacion_emision_privada.php', '(Inv calza) Construccion de notificacion calce', 'SELECT 	\n		E.cod_emision,\n		O.num_operacion,\n		J.des_nick_name as nick_cooperativa,\n		format(O.mon_transado,2) as mon_transado,\n		format(E.mon_facial,2) as mon_facial,\n		E.cod_instrumento,\n		P.des_periodicidad,\n		M.des_tipo_moneda,\n		format(C.mon_calce,2) as mon_calce,\n		I.des_nick_name as nick_inversionista,\n		format(O.num_rendimiento,1) as num_rendimiento,\n		C.fec_hora_calce,\n		format(OBTENER_SALDO_TITULO_PRIVADO(E.cod_emision),2) as Saldo_titulo,\n		format(OBTENER_SALDO_CAPTACION_PRIVADA(O.num_operacion,E.cod_emision),2) as Saldo_Captacion,\n		O.cod_vendedor,						\n		DATE_FORMAT(O.fec_liquidacion,%d %b %Y) as fec_liquidacion,\n		DATE_FORMAT(O.fec_vencimiento,%d %b %Y) as fec_vencimiento,\n		format(( ( (1 + C.num_rendimiento / 100 ) / ( 1 + (ME.mon_comision_lending / 100) / (O.cod_tipo_plazo / 365)) ) - 1 ) * 100 ,2) as RendAnualNeto,\n		format((C.mon_calce + OBTENER_COMISION (C.mon_calce,C.num_rendimiento,O.num_descuento,O.cod_tipo_plazo,T.cod_moneda_instrumento,C.cod_comprador,O.cod_tipo_factura, O.ind_operacion_liquidada, 1, 1) ),2) as NetoPagar,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS018) as c_dol_ATA,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS021) as c_col_ATA,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS019) as cta_dol_ATA,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS022) as cta_col_ATA,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS023) as iban_col_ATA,\n		(SELECT val_parametro FROM sis_parametros WHERE cod_parametro = SIS020) as iban_dol_ATA\n																\n		FROM sis_operaciones_pymes O \n		INNER JOIN sis_emisiones_privadas E ON E.cod_emision = O.cod_emision\n		INNER JOIN sis_catalogo_instrumentos T ON T.cod_instrumento = E.cod_instrumento\n		INNER JOIN sis_calces_captaciones_pymes C ON C.cod_emision = E.cod_emision and C.num_operacion = O.num_operacion and C.num_rendimiento = O.num_rendimiento\n		INNER JOIN sis_catalogo_juridicos J ON ', 'Consulta datos de operacion'),
(303, '2018-11-08 20:57:15', 'cbartels', '/primario/actualizacion_c_privada.php', 'Ln 272 Notificacion para clientes 152800006724 operacion # 1', 'enviar_notificaciones($con,$usr_registro,$compania,$idemp)', 'notificacion sin adjunto, enviada correctamente'),
(304, '2018-11-08 20:57:15', 'cbartels', '/primario/validar_usuario.php', 'Definir token cifrado', 'UPDATE sis_usuarios SET cod_clave=$2y$10$dOrQnqGo2UoTAnp2fTWvHe3XcwGmzU6I6fxQPfm5puNwgcQNvdRfa, cod_token = $2y$10$dOrQnqGo2UoTAnp2fTWvHe3XcwGmzU6I6fxQPfm5puNwgcQNvdRfa, fec_hora_fin_sesion = DATE_ADD(now(),INTERVAL 2 HOUR) where cod_usuario = cbartels', 'Paso 1, Se encripta la clave y token'),
(305, '2018-11-08 20:57:15', 'cbartels', '/primario/validar_usuario.php', 'Validacion para saber si usuario es ejecutivo activo', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 152800006724 AND cod_estado = A', 'Paso 2, Verificacion de cedulas'),
(306, '2018-11-08 20:57:15', 'cbartels', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en COLONES', 'SELECT `num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono` FROM `sis_ejecutivos` WHERE num_cedula = 152800006724 AND cod_estado = A', 'Paso 3, Lectura parametro PRM001'),
(307, '2018-11-08 20:57:15', 'cbartels', '/primario/validar_usuario.php', 'Valor de multiplos para certificados/titulos en DOLARES', 'SELECT val_parametro FROM sis_parametros where cod_parametro = PRM002', 'Paso 4, Lectura parametro PRM002'),
(308, '2018-11-08 20:57:15', 'cbartels', '/primario/validar_usuario.php', 'Datos del carrusel', 'SELECT O.num_operacion,\r\n						O.cod_vendedor,\r\n						O.mon_facial,\r\n						O.num_rendimiento,\r\n						J.des_nick_name,\r\n						M.des_tipo_moneda,\r\n						O.cod_tipo_plazo\r\n						FROM sis_operaciones_pymes O\r\n						inner join sis_catalogo_juridicos J ON J.num_identificacion = O.cod_vendedor\r\n						inner join sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda\r\n						WHERE O.cod_estado = 5', 'Paso 5, Lectura captaciones calzadas');

-- --------------------------------------------------------

--
-- Table structure for table `sis_calces_captaciones`
--

CREATE TABLE `sis_calces_captaciones` (
  `cod_calce_captacion` int(11) NOT NULL,
  `cod_emision` int(11) NOT NULL,
  `num_operacion` int(11) NOT NULL,
  `cod_comprador` varchar(45) COLLATE utf16_unicode_ci NOT NULL,
  `num_rendimiento` decimal(4,1) DEFAULT '0.0',
  `mon_calce` decimal(20,2) DEFAULT '0.00',
  `fec_hora_calce` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sis_calces_captaciones_pymes`
--

CREATE TABLE `sis_calces_captaciones_pymes` (
  `cod_calce_captacion` int(11) NOT NULL,
  `cod_emision` int(11) NOT NULL,
  `num_operacion` int(11) NOT NULL,
  `cod_comprador` varchar(45) COLLATE utf16_unicode_ci NOT NULL,
  `num_rendimiento` decimal(4,1) DEFAULT '0.0',
  `mon_calce` decimal(20,2) DEFAULT '0.00',
  `fec_hora_calce` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;

--
-- Dumping data for table `sis_calces_captaciones_pymes`
--

INSERT INTO `sis_calces_captaciones_pymes` (`cod_calce_captacion`, `cod_emision`, `num_operacion`, `cod_comprador`, `num_rendimiento`, `mon_calce`, `fec_hora_calce`) VALUES
(1, 1, 1, '152800006724', '10.0', '140000.00', '2018-11-08 10:57:15');

-- --------------------------------------------------------

--
-- Table structure for table `sis_catalogo_instrumentos`
--

CREATE TABLE `sis_catalogo_instrumentos` (
  `cod_instrumento` varchar(20) CHARACTER SET utf16 COLLATE utf16_unicode_ci NOT NULL,
  `des_nombre_instrumento` varchar(45) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `cod_moneda_instrumento` int(11) DEFAULT NULL,
  `cod_tipo_negocio` char(1) COLLATE utf8_unicode_ci NOT NULL,
  `fec_modificacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `usr_modificacion` varchar(45) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Tabla catalogo que describe los instrumentos de inversion';

--
-- Dumping data for table `sis_catalogo_instrumentos`
--

INSERT INTO `sis_catalogo_instrumentos` (`cod_instrumento`, `des_nombre_instrumento`, `cod_moneda_instrumento`, `cod_tipo_negocio`, `fec_modificacion`, `usr_modificacion`) VALUES
('ci_CRC', 'Cert. inversiones en Colones (CRc)', 1, 'C', '2018-08-06 09:08:33', 'dba'),
('ci_US$', 'Cert. inversiones en Dolares (US$)', 2, 'C', '2018-08-06 09:08:33', 'dba'),
('p_CRC', 'Bono / Certificado privado Colones (CRc)', 1, 'P', '2018-11-05 09:44:07', NULL),
('p_US$', 'Bono / Certificado privado Dolares (US$)', 2, 'P', '2018-11-05 09:44:07', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sis_catalogo_juridicos`
--

CREATE TABLE `sis_catalogo_juridicos` (
  `num_identificacion` varchar(50) COLLATE utf16_unicode_ci NOT NULL,
  `cod_tipo_identificacion` int(3) NOT NULL,
  `des_razon_social` varchar(500) COLLATE utf16_unicode_ci NOT NULL,
  `des_nick_name` varchar(50) COLLATE utf16_unicode_ci DEFAULT NULL COMMENT 'Nombre corto del deudor',
  `cod_nacionalidad` varchar(10) COLLATE utf16_unicode_ci DEFAULT NULL,
  `fec_constitucion` date DEFAULT NULL,
  `num_score` int(5) DEFAULT NULL,
  `cod_ejecutivo` varchar(50) COLLATE utf16_unicode_ci NOT NULL,
  `cod_ejecutivo_backup` varchar(50) COLLATE utf16_unicode_ci NOT NULL,
  `cod_tipo_membresia` int(5) NOT NULL,
  `num_cuenta_dolares` varchar(50) COLLATE utf16_unicode_ci DEFAULT NULL COMMENT 'Número cuenta dolares',
  `num_cuenta_colones` varchar(50) COLLATE utf16_unicode_ci DEFAULT NULL COMMENT 'Número cuenta colones',
  `num_cuenta_euros` varchar(50) COLLATE utf16_unicode_ci DEFAULT NULL COMMENT 'Cuenta en moneda Euros',
  `num_cta_colones_ATA` varchar(15) COLLATE utf16_unicode_ci DEFAULT NULL,
  `num_cta_dolares_ATA` varchar(15) COLLATE utf16_unicode_ci DEFAULT NULL,
  `num_cc_colones_ATA` varchar(17) COLLATE utf16_unicode_ci DEFAULT NULL,
  `num_cc_dolares_ATA` varchar(17) COLLATE utf16_unicode_ci DEFAULT NULL,
  `num_iban_colones_ATA` varchar(22) COLLATE utf16_unicode_ci DEFAULT NULL,
  `num_iban_dolares_ATA` varchar(22) COLLATE utf16_unicode_ci DEFAULT NULL,
  `num_cedula_rep_legal` varchar(50) COLLATE utf16_unicode_ci DEFAULT NULL,
  `des_nombre_rep_legal` varchar(100) COLLATE utf16_unicode_ci DEFAULT NULL,
  `des_direccion_rep_legal` varchar(250) COLLATE utf16_unicode_ci DEFAULT NULL,
  `cod_estado_civil_rep_legal` int(5) DEFAULT NULL,
  `des_profesion_rep_legal` varchar(50) COLLATE utf16_unicode_ci DEFAULT NULL,
  `des_nombre_contacto` varchar(100) COLLATE utf16_unicode_ci DEFAULT NULL,
  `des_telefono_contacto` varchar(50) COLLATE utf16_unicode_ci DEFAULT NULL,
  `des_correo_contacto` varchar(100) COLLATE utf16_unicode_ci DEFAULT NULL,
  `des_direccion_contacto` varchar(250) COLLATE utf16_unicode_ci DEFAULT NULL,
  `cod_actividad_economica` int(5) DEFAULT NULL,
  `ind_tipo_cliente` char(1) COLLATE utf16_unicode_ci NOT NULL DEFAULT 'X' COMMENT 'P = Pyme / C= Cooperativa / I = Inversionista / X = No indicado\n"Este campo es requerido para las cooperativas y Pymes"',
  `ind_es_fideicomiso` varchar(1) COLLATE utf16_unicode_ci DEFAULT NULL,
  `ind_tipo_representante_legal` varchar(1) COLLATE utf16_unicode_ci DEFAULT NULL,
  `cod_pais` varchar(10) COLLATE utf16_unicode_ci DEFAULT NULL,
  `cod_provincia` int(2) DEFAULT NULL,
  `cod_canton` int(5) DEFAULT NULL,
  `cod_distrito` int(8) DEFAULT NULL,
  `cod_tipo_sector` int(5) DEFAULT NULL,
  `mon_riesgo_inherente` decimal(10,4) DEFAULT NULL,
  `des_logo_cliente` varchar(50) COLLATE utf16_unicode_ci DEFAULT NULL,
  `des_descripcion` varchar(1000) COLLATE utf16_unicode_ci DEFAULT NULL,
  `des_aux_tipo` varchar(150) COLLATE utf16_unicode_ci DEFAULT NULL,
  `des_aux_valor` varchar(150) COLLATE utf16_unicode_ci DEFAULT NULL,
  `fec_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cod_usuario_modificacion` varchar(50) COLLATE utf16_unicode_ci NOT NULL DEFAULT 'gerson78'
) ENGINE=InnoDB DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci COMMENT='Tabla que almacena las sociedades o instituciones con cedula Juridica';

--
-- Dumping data for table `sis_catalogo_juridicos`
--

INSERT INTO `sis_catalogo_juridicos` (`num_identificacion`, `cod_tipo_identificacion`, `des_razon_social`, `des_nick_name`, `cod_nacionalidad`, `fec_constitucion`, `num_score`, `cod_ejecutivo`, `cod_ejecutivo_backup`, `cod_tipo_membresia`, `num_cuenta_dolares`, `num_cuenta_colones`, `num_cuenta_euros`, `num_cta_colones_ATA`, `num_cta_dolares_ATA`, `num_cc_colones_ATA`, `num_cc_dolares_ATA`, `num_iban_colones_ATA`, `num_iban_dolares_ATA`, `num_cedula_rep_legal`, `des_nombre_rep_legal`, `des_direccion_rep_legal`, `cod_estado_civil_rep_legal`, `des_profesion_rep_legal`, `des_nombre_contacto`, `des_telefono_contacto`, `des_correo_contacto`, `des_direccion_contacto`, `cod_actividad_economica`, `ind_tipo_cliente`, `ind_es_fideicomiso`, `ind_tipo_representante_legal`, `cod_pais`, `cod_provincia`, `cod_canton`, `cod_distrito`, `cod_tipo_sector`, `mon_riesgo_inherente`, `des_logo_cliente`, `des_descripcion`, `des_aux_tipo`, `des_aux_valor`, `fec_creacion`, `cod_usuario_modificacion`) VALUES
('104131393', 1, 'MANUEL ENRIQUE ARGUEDAS VENEGAS', 'ENRIQUE ARGUEDAS', 'CR', '2018-10-14', 1, '3101727041', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '104131393', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'N', 'N', '', '', 0, 0, 0, 0, '0.0000', NULL, '', '', '', '2018-06-01 16:03:35', 'Gerson'),
('105480569', 1, 'Victor Bejarano', 'Victor Bejarano', 'CR', '2017-04-19', 1, '2147483647', '', 2, '', '15100010011922440', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 2, '', '', '88958175', 'gguillen@masterzon.com', '', 0, 'N', 'N', '', '1', 1, 1, 1, 1, '1.0000', NULL, NULL, NULL, NULL, '2017-05-11 18:36:19', 'Gerson'),
('106900999', 1, 'Rodolfo de la Trinidad Solis Herrera', 'Cuenta de persona fisica.', 'cr', '2017-10-11', 1, '1', '0', 10, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '106900999', 'Rodolfo de la Trinidad', 'N/R', 1, '0', 'N/R', 'Rodolfo de la Trinidad', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-10-11 09:30:09', 'WEB'),
('108850253', 1, 'MARIO JOSE RAMIREZ AGUILAR', 'Mario Ramirez', 'cr', '2017-10-10', 1, '2147483647', '0', 2, '0', ' 15104420010063381', '0', NULL, NULL, NULL, NULL, NULL, NULL, '108850253', 'Mario José Ramírez Aguilar', 'San Joaquín de Flores, Heredia', 4, 'Ingeniero Agrónomo', 'Mario José Ramírez Aguilar', '83993622', 'gguillen@masterzon.com', 'San Joaquín de Flores, Heredia', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', '', '', '', '2017-11-30 20:53:02', 'Francisco Ulate Azofeifa'),
('109120257', 1, 'Jairo Solano Monge', 'Jairo Solano Monge', 'cr', '2017-11-14', 1, '1', '0', 10, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '109120257', 'Jairo', 'N/R', 1, '0', 'N/R', 'Jairo', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-11-14 15:52:00', 'WEB'),
('109260511', 1, 'ELIO ROJAS ROJAS', 'ELIO', 'crc', '2016-10-04', 0, '109260511', '', 8, '10200009240919780', '10200009216794112', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0', 'n/r', 'n/r', 1, '0', '', '', 'gguillen@masterzon.com', '', 0, 'N', '', '', '', 0, 0, 0, 0, '0.0000', NULL, '', '', '', '2018-05-21 16:50:07', 'Gerson'),
('109460803', 1, 'Rodolfo Carrillo Mena', 'Rodolfo Carrillo Mena', 'cr', '2017-10-12', 1, '2147483647', '0', 10, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '109460803', 'Rodolfo', 'N/R', 1, '0', 'N/R', 'Rodolfo', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', '', '', '', '2017-10-13 00:55:52', 'Gerson'),
('109470074', 1, 'Cuenta de persona fisica.', 'Cuenta de persona fisica.', 'cr', '2017-11-20', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '109470074', 'Andres', 'N/R', 1, '0', 'N/R', 'Andres', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-11-20 05:47:09', 'WEB'),
('109500718', 1, 'Cuenta de persona fisica.', 'Manfred Aguero D.', 'cr', '2017-12-13', 1, '801070063', '0', 2, '0', '81400011007766040', '0', NULL, NULL, NULL, NULL, NULL, NULL, '109500718', 'Manfed', 'San Jose, Mora, Guayabo, 25 metros norte de la Escuela Adela Rodriguez', 1, 'Administrador', 'Manfred Aguero D.', '87206108', 'gguillen@masterzon.com', 'San Jose, Mora, Guayabo, 25 metros norte de la Escuela Adela Rodriguez', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', '', '', '', '2017-12-13 17:22:36', 'Gerson'),
('110110991', 1, 'EDGAR OVIEDO BLANCO', 'EDGAR OVIEDO BLANCO', 'cr', '2017-11-02', 1, '1', '0', 10, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '110110991', 'EDGAR', 'N/R', 1, '0', 'N/R', 'EDGAR', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-11-02 09:56:10', 'WEB'),
('110310902', 1, 'Carmelo Enrique Solis Jimenez', 'Carmelo Enrique Solis Jimenez', 'cr', '2017-11-20', 1, '1', '0', 10, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '110310902', 'Carmelo Enrique', 'N/R', 1, '0', 'N/R', 'Carmelo Enrique', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-11-20 14:16:57', 'WEB'),
('110530424', 1, 'Virginia María Gómez Gómez', 'Ejecutiva', 'CR', '2017-02-16', 1, '110530424', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '110530424', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'N', '', '', '', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2017-02-16 20:17:47', 'Gerson'),
('11058037', 1, 'Esteban Vargas Gomez', 'Esteban Vargas', 'CR', '2017-03-07', 1, '1', '', 2, '15202001162677374', '15202942000070051', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 2, 'Dentista, Costarricense, ', 'Esteban Vargas Gomez', '88249590', 'gguillen@masterzon.com', '', 0, 'N', '', '', '', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2017-03-07 17:32:36', 'Gerson'),
('110610737', 1, 'Cuenta de persona fisica.', 'Cuenta de persona fisica.', 'cr', '2017-12-26', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '110610737', 'Manuel', 'N/R', 1, '0', 'N/R', 'Manuel', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-12-26 23:19:54', 'WEB'),
('110680863', 1, 'Ana Laura', 'Ana Laura', 'cr', '2017-09-07', 1, '2147483647', '0', 8, '15108420020087409', '11400007316066796', '0', NULL, NULL, NULL, NULL, NULL, NULL, '110680863', 'Ana Laura', 'Santa Ana, Pozos ', 2, 'Relaciones Publicas ', 'N/R', '0', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', '', '', '', '2017-09-07 22:19:40', 'Jose Rivas'),
('111460989', 1, 'Cuenta de persona fisica.', 'Cuenta de persona fisica.', 'cr', '2018-07-18', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '111460989', 'Wendy', 'N/R', 1, '0', 'N/R', 'Wendy', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-07-18 08:48:53', 'WEB'),
('112830963', 2, 'Micro Solutions Enterprises', 'Micro Solutions Enterprises', 'CR', '2018-02-09', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '112840963', 'Victor', 'N/R', 1, '0', 'N/R', 'Victor', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-02-09 06:17:09', 'WEB'),
('113310539', 1, 'Adrian Campos Oviedo', 'Adrian Campos Oviedo', 'cr', '2017-10-12', 1, '801070063', '0', 10, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '113310539', 'Adrian', 'N/R', 1, '0', 'N/R', 'Adrian', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', '', '', '', '2017-10-13 00:56:58', 'Gerson'),
('115240900', 1, 'Cuenta de persona fisica.', 'Cuenta de persona fisica.', 'cr', '2017-11-14', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '115240900', 'Francisco', 'N/R', 1, '0', 'N/R', 'Francisco', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-11-14 15:34:44', 'WEB'),
('125000094724', 1, 'Michel Satger', 'Michel Satger', '', '2017-04-19', 1, '206440727', '', 2, '11400007415136682', '81610300016153485', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 2, '', '', '', 'gguillen@masterzon.com', '', 0, 'N', '', '', '', 0, 0, 0, 0, '0.0000', NULL, '', '', '', '2017-09-22 22:00:49', 'Jose Rivas'),
('152800006724', 1, 'CORNELIA MARIA MAGDALENA BARTELS', 'Cora_Bartels', '188', '2016-12-01', 1, '109260511', '', 2, 'CR29010200009323246277', 'CR68010200009323246351', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '152800006724', '', '', 1, '', '', '88428080', 'gguillen@masterzon.com', '', 0, 'N', '', '', '188', 1, 1, 1, 1, '1.0000', NULL, '', '', '', '2018-05-04 22:05:16', 'Francisco Ulate Azofeifa'),
('206530872', 1, 'Cuenta de persona fisica.', 'Cuenta de persona fisica.', 'cr', '2018-02-11', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '206530872', 'JosÃ© Pablo', 'N/R', 1, '0', 'N/R', 'JosÃ© Pablo', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-02-11 16:58:05', 'WEB'),
('2100042000829', 2, 'Ministerio de Obras Publicas y Transporte', 'MOPT', 'cr', '1948-05-08', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', 'N', '', '188', 1, 1, 1, 1, '1.0000', 'images/logo_mopt.png', 'En 1860 dada la importancia que iban adquiriendo los edificios pÃºblicos, caminos y demÃ¡s obras construidas por cuenta de los fondos nacionales o de las provincias, se considerÃ³ pertinente crear una instituciÃ³n con el objeto de que Ã©stas se construyeran bajo su responsabilidad y en consideraciÃ³n con las reglas del arte......... <a href=\'http://www.mopt.go.cr/wps/portal/Home/acercadelministerio/informaciondelmopt/!ut/p/z1/04_Sj9CPykssy0xPLMnMz0vMAfIjo8ziPQPcDQy9TQx83M2CXAwcLX18TN38DYwtwgz0w8EKDFCAo4FTkJGTsYGBu7-RfhTp-pFNIqw_Cq-SIDOoAnxOxKIAxQ0FuaERBpmeigAQwbes/dz/d5/L2dBISEvZ0FBIS9nQSEh/\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:35:29', 'Francisco Ulate Azofeifa'),
('2100042002', 2, 'MINISTERIO DE EDUCACION PUBLICA', 'MEP', 'CR', '1965-03-13', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '', 0, 0, 0, 1, '0.0000', 'images/mep.png', 'La Ley No. 3481 establece la función del MEP de administrar todos los elementos que lo integran, para la ejecución de las disposiciones pertinentes del Título Sétimo de la Constitución Política de la Ley Fundamental de Educación de las leyes conexas y de los respectivos reglamentos.... <a href=\'http://www.mep.go.cr/transparencia-institucional/informacion/ley-organica\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:35:52', 'Francisco Ulate Azofeifa'),
('2100042006', 2, 'MINISTERIO DE JUSTICIA Y PAZ', 'MIN. JUSTICIA', 'CR', '1870-08-20', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', 'N', '', '188', 1, 1, 1, 1, '1.0000', 'images/MJP.png', 'La Constitucion Politica de 1847 creo el Ministerio de Relaciones Interiores, Exteriores, GobernaciÃ³n, Justicia y Negocios EclesiÃ¡sticos. Un aÃ±o despuÃ©s, se modificÃ³ esa ConstituciÃ³n y desaparece la nomenclatura de \"Justicia\". La cartera de Justicia fue constituida mediante decreto N.Â° 29 del 20 de junio de 1870, que creÃ³ el \"Reglamento de Gobierno y Atribuciones de la SecretarÃ­a de Estado\", firmado por ... <a href=\'http://www.mjp.go.cr/Acerca?nom=historia-institucional\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:36:13', 'Francisco Ulate Azofeifa'),
('2100042011', 2, 'MINISTERIO DE SEGURIDAD PUBLICA', 'MSP', 'CRC', '1973-12-24', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/MSP.png', '1923: El presidente Julio Acosta elimina el Ministerio de Guerra,el cual fue reemplazado por el Ministerio de Seguridad Publica y las actividades militares pasaron a un segundo plano. El 13 de abril de ese mismo año, mediante la Ley numero 93, se creo la Direccion de Investigaciones Criminales<a href=\'http://www.seguridadpublica.go.cr/ministerio/documentos/historia_msp.pdf\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:36:30', 'Francisco Ulate Azofeifa'),
('2100045222', 2, 'PATRONATO DE CONSTRUCCIONES, INSTALACIONES Y ADQUISICION DE BIENES', 'PATRONATO DE CONSTRUCCIONES', NULL, '1971-05-08', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/2100045222.png', 'El Patronato de Construcciones, Instalaciones y Adquisición de Bienes (PCIAB) es un órgano adscrito al Ministerio de Justicia y Paz, creado en la Ley de la Dirección General de Adaptación Social No. 4762 del 8 de mayo de 1971; pertenece al Sector Justicia, su función principal es coadyuvar tanto en el desarrollo y mejoramiento de la infraestructura penitenciaria como de las condiciones de vida de las personas privadas de libertad.', '', '', '2018-01-15 17:59:58', 'Francisco Ulate Azofeifa'),
('21651651', 1, 'Cuenta de persona fisica.', 'Cuenta de persona fisica.', 'cr', '2017-10-12', 1, '1', '0', 10, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '21651651', 'don', 'N/R', 1, '0', 'N/R', 'don', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-10-12 13:24:24', 'WEB'),
('2300042155', 2, 'CORTE SUPREMA DE JUSTICIA PODER JUDICIAL', 'CORTE SUPREMA', 'CR', '1825-01-25', 2, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '', 0, 0, 0, 1, '0.0000', 'images/PJ.png', 'Con la Independencia de Costa Rica, el 15 de setiembre de 1821, los costarricenses se organizaron polÃ­ticamente y constituyeron un gobierno propio. Para el 1Â° de diciembre de 1821, los representantes de diferentes ciudades y pueblos de aquel entonces, formularon el Pacto Social Fundamental Interino de Costa Rica, conocido como el Pacto de Concordia, considerado como el primer documento constitucional de Costa Rica..... <a href=\'https://www.poder-judicial.go.cr/principal/index.php/informacion-institucional\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:36:49', 'Francisco Ulate Azofeifa'),
('3002045433', 2, 'ASOCIACION CRUZ ROJA COSTARRICENSE', 'CRUZ ROJA', NULL, '1952-01-01', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/3002045433.jpg', 'Somos una Institución humanitaria de  carácter voluntario y de interés público,  con programas de atención de emergencias pre hospitalarias, respuesta a calamidades o desastres, promoción de la resiliencia comunitaria, el fomento de la no violencia y la cultura de paz, los cuales se desarrollan a través de 122 comités auxiliares (representaciones locales), 9 juntas regionales que integran para efectos administrativos y operativos a los comités auxiliares  y varias direcciones nacionales.', '', '', '2018-05-30 22:37:08', 'Francisco Ulate Azofeifa'),
('3002075697', 2, 'Asociacion Solidarista de Empleados de Cía Galletas Pozuelo DCR, S.A. Asdepsa', 'ASDEPSA', 'cr', '2017-10-06', 1, '206440727', '0', 2, '0', '10200009022937034	', '0', NULL, NULL, NULL, NULL, NULL, NULL, '108160212', 'Amalia Cavallo Aita', '1.5 km al oeste del BAC San José, San Rafael, Escazú, San José', 2, 'Ingeniera Industrial', 'Heidy María Bermúdez Flores', '2299-1249', 'gguillen@masterzon.com', '350 metros al norte del Puente Juan Pablo Segundo, La Uruca, San José', 1, 'X', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', 'images/ASDEPSA.jpg', '', '', '', '2017-12-06 15:08:43', 'Rafael Villalobos'),
('3002078587', 2, 'ASECEMEX', 'ASECEMEX', 'Costa Rica', '2017-05-01', 1, '206440727', '', 2, '', '10200009016526367', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '502650080', 'JOSE ANGEL CORTEZ CRUZ', 'GUANACASTE', 2, 'ADMINISTRACIÓN DE EMPRESA, Costarricense, ', '', '', 'gguillen@masterzon.com', '', 0, 'N', '', 'A', '', 0, 0, 0, 0, '0.0000', 'images/ASECEMEX.jpg', '', '', '', '2018-03-01 17:20:25', 'Jose Rivas'),
('3002078847', 2, 'ASOCIACIÓN SOLIDARISTA DERIVADOS DEL MAIZ ALIMENTICIO S.A', 'ASEDEMASA', NULL, '2010-11-01', NULL, '2147483647', '', 2, '', '15100010011642522', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '401650262', 'Randall Espinoza Romero', 'Mercedes Norte, Heredia, de la Capilla San Isidro 150 oeste y 50 norte', 2, 'Ingeniero Industrial', 'Pamela Delgado Guadamuz', '22311978', 'gguillen@masterzon.com', '2 km oeste de la Embajada Americana, Pavas, San José', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/3002078847.png', 'Somos una Asociación Solidarista que procura la justicia, la paz social y la armonía obrero patronal, para el desarrollo integral de los asociados y sus familias, mediante el fomento del ahorro y la administración eficiente de los recursos, somos trabajadores de la empresa Derivados del Maíz S.A, la cual pertenece al Grupo Maseca.', '', '', '2018-05-18 22:00:31', 'Francisco Ulate Azofeifa'),
('3002152430', 2, 'ASEHNN', 'ASEHNN', 'cr', '2017-12-15', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '111180313', 'Graciela', 'N/R', 1, '0', 'N/R', 'Graciela', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-12-15 07:57:52', 'WEB'),
('3002204388', 2, 'ASOCIACION SOLIDARISTA DE EMPLEADOS DE SYKES LATIN AMERICA S.A', 'ASOSYKES', 'cr', '1997-06-12', 1, '2147483647', '0', 2, '0', '44015201001024618894', '0', NULL, NULL, NULL, NULL, NULL, NULL, '113050328', 'Rebeca Guadamuz Ramirez', 'La Aurora de Heredia', 1, 'Comunicadora', 'Stephanie Herrera Ferreto', '89033693', 'gguillen@masterzon.com', 'La Aurora de Heredia', 1, 'X', 'N', '', 'CR', 1, 1, 1, 2, '0.0000', 'images/ico_asoskyes.png', 'AsoSykes es una asociacion que busca darle un excelente servicio al empleado de Sykes y por lo cual dia a dia trabajamos para ser un reflejo claro del solidarismo.', '', '', '2018-03-07 17:00:32', 'Jose Rivas'),
('3002396430', 2, 'ASEBOSTON', 'ASEBOSTON', 'CR', '2017-05-08', 1, '206440727', '', 2, '12300003031812010', '12300003031812004', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'N', 'N', '', '', 0, 0, 0, 0, '0.0000', 'images/ASEBOSTON.jpg', '', '', '', '2018-01-05 17:38:44', 'Jose Rivas'),
('3002454356', 2, 'ASOCIACION SOLIDARISTA DE EMPLEADOS DE UNILEVER CENTROAMERICA S.A', 'ASEUNILEVER', NULL, '2015-04-03', NULL, '3101727041', '', 2, '', '10200009092265814', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '206490617', 'Tatiana Arce Gonzalez', '125 oeste del Colegio Maria Inmaculada, Grecia, Alajuela', 2, 'Tecnóloga de alimentos', 'Gabriel Meléndez Montero', '87074895', 'gguillen@masterzon.com', 'San Antonio deBelén', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, '', '', '', '2018-06-19 20:17:41', 'Francisco Ulate Azofeifa'),
('3002662958', 2, 'ASOCIACIÓN SOLIDARISTA DE EMPLEADOS DEL MOPT', 'ASEMOPT', 'cr', '2012-10-05', 1, '206440727', '0', 2, '15201001041160111', '15113710010016059', '0', NULL, NULL, NULL, NULL, NULL, NULL, '303750577', 'Adrián Rodríguez Hernández', 'Residencial Los Faroles, Curridabat, San José', 2, 'Administrador de Empresas', 'Ana Priscilla Moreno', '88244338', 'gguillen@masterzon.com', 'Edificio MOPT, Plaza Víquez, San José', 1, 'X', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', 'Las intenciones y los esfuerzos por que en el MOPT existiera una Asociación Solidarista datan de los años 2000, cuando un grupo de compañeros sentían una necesidad imperante de contar con tan importante organización, en especial viendo el ejemplo de otros ministerios e incluso sus propios consejos que contaban con una. Pero no fue hasta el año 2012 que fue posible la constitución de esta empresa privada. En ese momento, por medio del DECRETO EJECUTIVO No 36313-MOPT se ordena al Consejo de Seguridad Vial (COSEVI) trasladar todas las plazas ocupadas por la Dirección General de la Policía de Tránsito, al Ministerio de Obras Públicas y Transportes. Este importante grupo de colaboradores contaban con asociación Solidarista en el COSEVI y esperaban no perder este beneficio al a ser trasladados de planilla. Fue así como el 5 de octubre 2012, se constituye la ASOCIACION SOLIDARISTA DE EMPLEADOS DEL MINISTERIO DE OBRAS PUBLICAS Y TRANSPORTES. Con 256 asociados, alcanzado a setiembre 2016, 1756 ', '', '', '2018-05-08 16:27:12', 'Francisco Ulate Azofeifa'),
('3002702894', 1, 'ASOCIACIÓN SOLIDARISTA DE EMPLEADOS DE ASEBOSTON', 'ASOA', NULL, '2015-07-01', NULL, '2147483647', '', 2, '12300130009378010', '12300130009378004', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '401240207', 'María Isabel Bolaños Murillo', '150 este del Más X Menos de San Antonio de Belén, Heredia', 2, 'Secretaria', 'Grettel Porras Solís', '24368407', 'gguillen@masterzon.com', 'Zona Franca Propark, contiguo a la Dos Pinos, Coyol de Alajuela', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, '', '', '', '2018-05-21 21:42:55', 'Francisco Ulate Azofeifa'),
('3004045002', 2, 'COOPERATIVA DE PRODUCTORES DE LECHE DOS PINOS R L', 'DOS PINOS', NULL, '1947-08-26', NULL, '206440727', '', 6, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 1, 'C', 'N', '1', '188', NULL, NULL, NULL, 2, NULL, 'images/dos_pinos.JPG', 'La Cooperativa nació en el marco del movimiento cooperativo que promovió la Sección de Fomento a cooperativas agrícolas e industriales por medio del Banco Nacional de Costa Rica. En el umbral de la crisis política que concluyó con la Guerra Civil de 1948 y en un panorama de desorganización de los mismos productores de leche, la tarde del 26 de agosto de 1947 veinticinco lecheros acordaron reunirse en la sede de la Cámara de Agricultura y Agroindustria.... <a href=\'http://www.dospinos.com/userfiles/file/pdf/backup_RESENA_HISTORICA_PDF.pdf\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2017-10-20 17:05:58', 'Gerson'),
('3004045027', 2, 'COOPERATIVA DE AHORRO Y CREDITO ANDE No.1, RL', 'COOPEANDE 1', 'CR', '2017-04-19', 1, '2147483647', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 1, 'C', 'N', '1', '188', 1, 1, 1, 1, '1.0000', NULL, NULL, NULL, NULL, '2017-04-19 18:54:03', 'Gerson'),
('3004045083', 2, 'COOPERATIVA DE CAFICULTORES Y SERVICIOS MULTIPLES DE TARRAZU R.L', 'COOPETARRAZU', 'CR', '1960-10-13', NULL, '206440727', '', 2, '15201332000011630 ', '15201332000004340 ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '601310715', 'Carlos Vargas Leitón', 'Calle Arenillas, Guadalupe, Cartago', 2, 'Administrador de Empresas', 'Jennifer Ulloa Jiménez', '89816521', 'gguillen@masterzon.com', 'San José, Tarrazú, San Marcos, 1 km al sur del parque', 1, 'C', 'N', '1', '188', NULL, NULL, NULL, 2, NULL, '/images/ico_tarrazu.png', 'COOPETARRAZÚ, Cooperativa de Caficultores y de Servicios Múltiples de Tarrazú RL es una cooperativa de pequeños cafetaleros que procesa y vende café producido en forma sostenible. COOPETARRAZÚ también gestiona supermercados, vende materiales agrícolas, financia cosechas y brinda asistencia técnica. COOPETARRAZÚ ha recibido varias certificaciones, entre ellas la certificación orgánica y la de comercio justo, gracias a sus mejores prácticas sociales y ambientales.  El café de COOPETARRAZÚ está considerado entre los mejores del mundo, gracias a su nivel de acidez favorable y a su sabor y cuerpo excelentes. Las marcas propias de café tostado y molido (Buen Día y El Marqués) gozan de fuertes ventas gracias a las campañas de mercadeo y distribución de COOPETARRAZÚ.  La cooperativa emprendió una serie de iniciativas ambientales, como por ejemplo la instalación de paneles solares.', '', '', '2018-02-05 23:04:18', 'Jose Rivas'),
('3004045111', 2, 'COOPERATIVA DE AHORRO Y CREDITO DE LOS SERVIDORES PUBLICOS R.L', 'COOPESERVIDORES R.L', 'CR', '2018-01-08', 1, '1', '0', 2, '15104710026001664', '15104710010015055', '0', NULL, NULL, NULL, NULL, NULL, NULL, '108180660', 'Mario Alberto Campos Conejo', 'N/R', 1, '0', 'N/R', 'JESÃšS ', 'gguillen@masterzon.com', 'N/R', 1, 'C', 'N', '1', '188', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-01-08 20:21:00', 'WEB'),
('3004045117', 2, 'COOPERATIVA DE ELECTRIFICACION RURAL DE SAN CARLOS R L', 'COOPELESCA', 'CR', '2017-03-12', 1, '2147483647', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 1, 'C', 'N', '1', '188', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2017-05-29 20:27:28', 'Jose Rivas'),
('3004045205', 2, 'Cooperativa Nacional de Educadores', 'COOPENAE', 'CR', '2017-06-01', 1, '801070063', '', 2, '15108010026013455', '15100010010531186', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '602400141', 'Johnny Gutierrez Delgado', '', 2, '', 'Johnny Gutierrez Delgado', '22579060', 'gguillen@masterzon.com', '', 1, 'C', 'N', '1', '188', 1, 1, 1, 1, '1.0000', 'images/coopenae.png', '', '', '', '2018-03-12 22:03:36', 'Francisco Ulate Azofeifa'),
('3007042030', 2, 'REGISTRO NACIONAL', 'REGISTRO ', 'CR', '2017-06-01', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', 'N', '', '188', 1, 1, 1, 1, '1.0000', 'images/registro.png', 'Los primeros intentos de publicidad registral encuentran su gÃ©nesis en una solicitud de las Cortes de Madrid de 1528, a partir de la cual se dicta una \"Real PragmÃ¡tica\" en 1539, la cual establecÃ­a que las ciudades o villas que fueran cabeza de jurisdicciÃ³n, debÃ­an llevar un libro identificado como Registro de Censos y Tributos, en los que se registran los contratos de censos e hipotecas.... <a href=\'http://www.registronacional.go.cr/Institucion/index.htm\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:37:44', 'Francisco Ulate Azofeifa'),
('3007045551', 2, 'CONSEJO TECNICO DE AVIACION CIVIL', 'AVIACION CIVIL', NULL, '1973-05-14', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3007045551.gif', 'Es el ente encargado de planificar, regular y proveer los servicios de la aviación civil en Costa Rica de forma ágil y transparente para garantizar y promover una actividad aeronáutica ordenada, eficiente, respetuosa con el medio ambiente, de calidad y segura que garantice la satisfacción de los usuarios y los intereses de la sociedad.', '', '', '2018-02-01 18:41:19', 'Francisco Ulate Azofeifa'),
('3007071587', 2, 'CORPORACION DE SERVICIOS MULTIPLES DEL MAGISTERIO NACIONAL', 'CORPORACION MAGISTERIO NACIONAL', NULL, '1985-07-11', NULL, '3101727041', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/3007071587.png', 'A traves de los años, el Magisterio Nacional ha logrado fundar varias Instituciones que hoy, ademas de ser un orgullo para los maestros, son un ejemplo para el pais, ya que se han convertido en empresas poderosas, con objetivos claramente definidos y cuya labor principal ha estado enfocada a una funcion eminentemente social.  De ahi nace en 1985 mediante la Ley de Presupuesto Extraordinario N. 6995, se introdujo la Norma N. 177, que creaba la Corporacion de Servicios Multiples del Magisterio Nacional.', '', '', '2018-07-18 22:08:03', 'Francisco Ulate Azofeifa'),
('3007075876', 2, 'INSTITUTO NACIONAL DE LAS MUJERES (INAMU)', 'INAMU', 'Costa Rica', '1998-04-08', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1111111', 'Alejandra Mora Mora', 'OFICINAS CENTRALES', 2, 'Trabajadora social, Costarricense, ', '', '25278400', 'gguillen@masterzon.com', 'San Jose', 0, 'X', 'N', '', '', 0, 0, 0, 1, '0.0000', 'images/inamu.png', 'Desde hace mÃ¡s de veinte aÃ±os, con diferentes denominaciones y caracterÃ­sticas especÃ­ficas, han ido surgiendo en los paÃ­ses mecanismos nacionales de promociÃ³n de las mujeres, tambiÃ©n conocidos como Oficinas Gubernamentales de la Mujer (OGM).alt....... <a href=\'http://www.inamu.go.cr/9\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:32:17', 'Francisco Ulate Azofeifa'),
('3007111111', 2, 'COMISION NACIONAL DE PREVENCION DE RIESGOS Y ATENCION DE EMERGENCIAS', 'CNE', 'CR', '1986-05-01', 0, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '', 0, 0, 0, 1, '0.0000', 'images/CNE_logo.png', 'Institución pública rectora en lo referente a la coordinación de las labores preventivas de situaciones de riesgo inminente, de mitigación y de respuesta a situaciones de emergencia. Es un órgano de desconcentración máxima adscrito a la Presidencia de la República,.... <a href=\'https://www.cne.go.cr/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:31:02', 'Francisco Ulate Azofeifa'),
('3007231686', 1, 'CONSEJO NACIONAL DE VIALIDAD', 'CONAVI', 'CR', '1996-02-02', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'S', '', '', '', 0, 0, 0, 1, '0.0000', 'images/conavi_.png', 'En el año 1996, se empezó a gestar en nuestro país un movimiento orientado a establecer un fondo vial financiado con un impuesto único al combustible. Este movimiento se basa en la experiencia positiva de otros países latinoamericanos como Chile, Argentina Colombia...<a href=\'http://www.conavi.go.cr/wps/portal/CONAVI\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:31:28', 'Francisco Ulate Azofeifa'),
('3007270500', 2, 'CONSEJO DE TRANSPORTE PUBLICO', 'CTP', 'CR', '2000-03-28', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '', 0, 0, 0, 1, '0.0000', 'images/CTP.png', 'El Consejo de Transporte Público, fue creado mediante la Ley 7969 (Ley Reguladora del Servicio Público del Transporte Remunerado de Personas en Vehículos en la Modalidad Taxi), publicada en el Diario Oficial “La Gaceta” No. 20, el 28 de febrero 2000, como órgano de desconcentración máxima, adscrito al Ministerio de Obras Públicas y Transportes.... <a href=\'http://www.ctp.go.cr/index.php?option=com_content&view=article&id=92&Itemid=107\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:31:53', 'Francisco Ulate Azofeifa'),
('3007320067', 2, 'INSTITUTO NACIONAL DE INNOVACION TECNOLOGICA AGROPECUARIA INTA', 'INTA', NULL, '2016-11-13', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '', '', '', '2018-05-30 22:32:35', 'Francisco Ulate Azofeifa'),
('3007521568', 2, 'Servicio Fitosanitario del Estado', 'SFE', 'Costa Rica', '1978-05-02', 0, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', 'Sabana Sur, San José.', 1, '', '', '25493400', 'gguillen@masterzon.com', '', 0, 'X', 'N', '', 'Costa Rica', 0, 0, 0, 1, '0.0000', 'images/ico_sfe.jpg', 'En 1975, dentro del MAG, se origina la Dirección de Servicios Técnicos Básicos, que más tarde daría paso a la creación de la Dirección de Sanidad Vegetal, cuyo nombre se oficializa con la publicación de la Ley No.6248 del 2 de mayo de 1978, en la Administración del Lic. Daniel Oduber.. <a href=\'https://www.sfe.go.cr/SitePages/QuienesSomos/InicioQuienesSomos.aspx\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:38:44', 'Francisco Ulate Azofeifa'),
('3007547060', 2, 'BENEMERITO CUERPO DE BOMBEROS DE COSTA RICA', 'BOMBEROS CR', NULL, '1925-05-29', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'images/3007547060.png', 'Somos el ente rector en materia de capacitación para la atención y prevención de emergencias que son competencia del Cuerpo de Bomberos, brindamos un servicio de excelencia en todas nuestras actividades, con abnegación, honor y disciplina desde 1925.', '', '', '2018-01-17 18:03:41', 'Francisco Ulate Azofeifa'),
('3007661162', 2, 'UNIDAD EJECUTORA DEL PROGRAMA PARA LA PREVENCION DE LA INCLUSION SOCIAL', 'MINISTERIO DE JUSTICIA Y PAZ', NULL, '2016-10-09', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '/images/ico_BID.png', 'El objetivo general del Programa será contribuir a la prevención de la violencia y el delito en las áreas de intervención. El objetivo específico del Programa será fortalecer las capacidades de gestión y acción del MJP para ejecutar intervenciones en sus dos principales áreas de actuación: (i) prevención secundaria de la violencia a nivel nacional y local y (ii) rehabilitación y reinserción de la población en conflicto con la ley penal, a través de programas de prevención terciaria de la violencia...<a href=\"http://mjp.go.cr/uep/\" target=\"_black\"><img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:39:07', 'Francisco Ulate Azofeifa'),
('301123456', 2, 'Nombre de la empresa', 'Nombre de la empresa', 'CR', '2017-12-20', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '1 1803 0131', 'Nicolas', 'N/R', 1, '0', 'N/R', 'Nicolas', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-12-20 06:51:38', 'WEB'),
('3012682635', 2, 'STEREOCARTO S.L.', 'STEREOCARTO', 'ESPAÑOLA', '1965-01-01', 2, '206440727', '', 2, '15108410026012078', '15108410010019531', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'AAB486058', 'Maria Soraya Colino Jimenez', 'San José, La Uruca, condominio Vía Millenium, apartamento No. 401, 100 este del ICT avenida 31', 1, 'Ingeniera, nacionalidad Española, ', 'Alfonso Gómez Molina', '60272377', 'gguillen@masterzon.com', 'San José, Central, Uruca, Condominio Vía Millenium Apto 401', 0, 'P', '', 'A', 'CR', 1, 1, 7, 2, '1.0000', 'images/stereoCarto.png', 'En STEREOCARTO, hemos empleado medios propios para la captura de informacion espacial, realizando mas de siete mil horas de vuelo fotogramatrico con nuestros aviones Cessna, Partenavia y Beechcraft para obtención de imágenes areas con cámaras fotogramátricas Zeiss Intergraph y Leica, y datos LIDAR con sensores Leica, cubriendo más de quinientos millones de hectÃ¡reas con fotografÃ­a vertical y nubes de puntos láser, en mas de veinte paises de cuatro continentes.... <a href=\'http://stereocarto.com/inicio\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-07-12 18:23:29', 'Rafael Villalobos'),
('3014042047', 1, 'MUNICIPALIDAD DE CURRIDABAT', 'MUN. CURRIDABAT', 'CR', '1929-08-21', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'S', '', '', '', 0, 0, 0, 1, '0.0000', 'images/mun_curri.png', 'Curridabat es un cantón con antecedentes precolombinos, conformado en sus inicios por grupos indígenas huetares, de los cuales descienden los primeros poblados del lugar... <a href=\'http://www.curridabat.go.cr/resena-historica/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:39:36', 'Francisco Ulate Azofeifa'),
('3014042048', 2, 'MUNICIPALIDAD DE DESAMPARADOS', 'MUNI.DESAMPARADOS', NULL, '1862-11-04', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042048.png', 'La Municipalidad de Desamparados procura que el cantón desarrolle su máximo potencial, en un pueblo que combina el territorio urbano y rural y cuya principal fortaleza son sus habitantes que trabajan en el día a día para lograr un mejor lugar para vivir y trabajar', '', '', '2018-02-01 17:15:16', 'Francisco Ulate Azofeifa'),
('3014042050', 2, 'MUNICIPALIDAD DE ESCAZU', 'MUNI.ESCAZU', NULL, '1848-12-07', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042050.png', 'La Municipalidad de Escazú es el ente rector de la administración y desarrollo de los habitantes del cantón de Escazú, de la provincia de San José, procurando el bienestar de todos sus habitantes y el manejo eficiente de los recursos.', '', '', '2018-02-01 17:38:17', 'Francisco Ulate Azofeifa'),
('3014042054', 2, 'MUNICIPALIDAD DE MORA', 'MUNICIPALIDAD DE MORA', NULL, '1883-05-25', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042054.jpg', 'La Municipalidad de Mora es la rectora del canton numero 7 de la provincia de San Jose, Costa Rica, establecido en 1883 con el nombre indigena de Pacaca, que en esa epoca llevaba la poblacion cabecera posteriormente denominada Colon, con la categoria de villa y actualmente Colon (hoy con categoria de ciudad). Mora fue calificado en el año 2011 como el Canton mas seguro de todo el pais, debido a su formacion rural y a su extremadamente bajo nivel de delincuencia, el cual es practicamente imperceptible.', '', '', '2018-05-24 20:52:54', 'Francisco Ulate Azofeifa'),
('3014042058', 2, 'MUNICIPALIDAD  DE SAN JOSE', 'MUNI.SAN JOSE', 'CR', '1841-01-01', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '', 0, 0, 0, 1, '0.0000', 'images/msj.gif', 'En 1841, gracias a la promulgaciÃ³n de la Ley de Bases y GarantÃ­as, se establece un nuevo ordenamiento territorial del paÃ­s, en forma de cinco departamentos, con sus capitales en San JosÃ©, Cartago, Heredia, Alajuela y Guanacaste, y con la divisiÃ³n de cada uno de los departamentos en pueblos, barrios y cuarteles... <a href=\'https://www.msj.go.cr/MSJ/Capital/SitePages/historia_canton.aspx\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:40:21', 'Francisco Ulate Azofeifa'),
('3014042059', 2, 'MUNICIPALIDAD DE SANTA ANA', 'MUN. SANTA ANA', NULL, '1907-10-15', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/muni_staana.png', 'En 1870 el Gobierno del General Guardia estableció la primera Alcaldía en Santa Ana, en Río de Oro. Santa Ana nace como cantón el 31 de agosto de 1907, mediante el Decreto No. 8 del 29 de agosto de 1907.... <a href=\'https://www.santaana.go.cr/\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:40:47', 'Francisco Ulate Azofeifa'),
('3014042060', 2, 'MUNICIPALIDAD DE TARRAZU', 'MUNI.TARRAZU', NULL, '1868-08-07', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042060.jpg', 'Es el ente gubernamental encargado del desarrollo y administración del cantón de Tarrazú, de la provincia de San José, procurando las mejores vías para el desarrollo de todos sus vecinos, brindándoles los mejores servicios para este fin.', '', '', '2018-02-01 17:22:20', 'Francisco Ulate Azofeifa'),
('3014042061', 2, 'MUNICIPALIDAD DE TIBAS', 'MUNI.TIBAS', NULL, '1914-07-27', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042061.jpg', 'La Municipalidad de Tibás es el órgano encargado de la administración del cantón de Tibás, de la provincia de San José, promoverá la mejora en la calidad de vida de todos sus habitantes y el mejor manejo de sus recursos.', '', '', '2018-02-01 18:10:46', 'Francisco Ulate Azofeifa'),
('3014042062', 1, 'MUNICIPALIDAD DE TURRUBARES', 'MUN. TURRUBARES', 'CR', '2017-05-07', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'S', '', '', '', 0, 0, 0, 1, '0.0000', 'images/escudo+de+turrubares.png', 'Procedentes del sur del Valle Central occidental, en 1850 aproximadamente, numerosas familias buscaron las montaÃ±as aledaÃ±as con el afÃ¡n de nuevas y mÃ¡s productivas tierras. Entre viviendas alejadas al inicio y agrupadas poco a poco, se va formando una especie de cuadrante  que con el paso del tiempo da base a la parroquia de Santiago de Puriscal.... <a href=\'http://www.turrubares.go.cr/Historia\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:41:16', 'Francisco Ulate Azofeifa'),
('3014042063', 2, 'MUNICIPALIDAD DE ALAJUELA', 'MUNI.ALAJUELA', NULL, '1848-12-07', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042063.jpg', 'La Municipalidad de Alajuela se creó por decreto el 7 de diciembre de 1848. Es el gobierno local del cantón central de la provincia de Alajuela, su función primordial es garantizar el bienestar de los Alajuelenses mediante una sana administración de los recursos, que permitan brindar servicios y obras locales de calidad, que brinden oportunidades para el desarrollo integral del Cantón en armonía con el ambiente. ', '', '', '2018-01-22 15:06:11', 'Francisco Ulate Azofeifa'),
('3014042066', 2, 'MUNICIPALIDAD DE GRECIA', 'MUNICIPALIDAD DE GRECIA', NULL, '2017-11-12', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '', '', '', '2018-05-30 22:41:38', 'Francisco Ulate Azofeifa'),
('3014042079', 2, 'MUNICIPALIDAD DE ALVARADO DE PACAYAS', 'MUNI.ALVARADO DE PACAYAS', NULL, '1903-07-17', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042079.jpg', 'La Municipalidad de Alvarado busca potenciar el desarrollo de los habitantes del cantón, garantizando mejor calidad de vida con el uso eficiente de los recursos. ', '', '', '2018-02-01 17:50:13', 'Francisco Ulate Azofeifa'),
('3014042080', 2, 'MUNICIPALIDAD DE CARTAGO', 'MUN. CARTAGO', 'cr', '1998-01-01', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '188', 1, 1, 1, 1, '1.0000', 'images/municartago.png', 'El Ayuntamiento de Cartago fue fundado en 1563, por ende es el ayuntamiento mÃ¡s antiguo de Costa Rica y constituyÃ³ el Gobierno de Costa Rica, por ser Cartago la capital en ese momento. Posteriormente en 1813, de acuerdo a la constituciÃ³n promulgada en CÃ¡diz, EspaÃ±a, en el aÃ±o 1812,.... <a href=\'http://www.muni-carta.go.cr/nuestra-municipalidad/resena-historica.html\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:42:03', 'Francisco Ulate Azofeifa'),
('3014042082', 2, 'MUNICIPALIDAD DE EL GUARCO', 'MUNICIPALIDAD DE EL GUARCO', NULL, '1939-07-26', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042082.png', 'Somos una institución amparada en el Régimen Municipal, que brinda servicios de calidad con continuidad, de forma democrática y participativa, contribuyendo al mejoramiento de la calidad de vida y al desarrollo humano local de los y las habitantes del cantón de El Guarco', '', '', '2018-02-01 17:15:48', 'Francisco Ulate Azofeifa'),
('3014042083', 2, 'MUNICIPALIDAD DE LA UNION', 'MUNI.LA UNION', NULL, '1848-12-07', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042083.png', 'Somos la institución rectora de La Unión, que impulsa el desarrollo socio-económico, cultural y recreativo, mejorando la calidad de vida de sus habitantes, en armonía con la naturaleza. Para lograrlo contamos con un equipo de trabajo motivado, comprometido y competitivo, apoyados en recursos materiales y tecnológicos idóneos.', '', '', '2018-02-01 17:14:28', 'Francisco Ulate Azofeifa'),
('3014042086', 2, 'MUNICIPALIDAD DE PARAISO', 'MUNI.PARAISO', NULL, '1848-12-07', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042086.jpg', 'Desarrollamos las capacidades institucionales y ciudadana disponibles en el cantón Paraíso, que mejoren la calidad de vida de sus habitantes en el marco del desarrollo humano, social, económico, político, y cultural, con equidad de género.', '', '', '2018-02-01 17:58:47', 'Francisco Ulate Azofeifa'),
('3014042088', 2, 'MUNICIPALIDAD DE TURRIALBA', 'MUNI.TURRIALBA', NULL, '1903-08-25', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042088.jpg', 'Somos el gobierno local que brinda servicios públicos, realiza y articula proyectos sociales, ambientales y económicos para los habitantes y su desarrollo integral en el cantón de Turrialba.', '', '', '2018-02-01 18:02:28', 'Francisco Ulate Azofeifa'),
('3014042092', 1, 'MUNICIPALIDAD DE HEREDIA', 'MUNI.HEREDIA', 'CR', '1848-12-07', 0, '801070063', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'S', '', '', 'Costa Rica', 0, 0, 0, 1, '0.0000', 'images/muni_heredia.png', 'La Municipalidad debe atender las funciones de:  fomentar la participaciÃ³n activa de la ciudadanÃ­a en la toma de decisiones, ofrecer servicios como recolecciÃ³n de residuos, limpieza de calles y caÃ±os, mantenimiento y construcciÃ³n de Ã¡reas pÃºblicas, la administraciÃ³n de cementerios municipales, administraciÃ³n del Mercado Municipal, mantenimiento y construcciÃ³n de vÃ­as cantonales.... <a href=\'https://www.heredia.go.cr/es/municipalidad\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-02-01 16:45:06', 'Francisco Ulate Azofeifa'),
('3014042097', 2, 'MUNICIPALIDAD DE SANTO DOMINGO', 'MUNI,STO DOMINGO', NULL, '1848-12-07', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3014042097.png', 'La Municipalidad de Santo Domingo tiene como misión la promoción de un desarrollo integral y sostenible de los habitantes  del cantón de Santo Domingo de Heredia; mediante la prestación eficiente de los servicios municipales, el desarrollo de proyectos y la aplicación de las  competencias de gobierno local.', '', '', '2018-02-01 17:02:06', 'Francisco Ulate Azofeifa'),
('301442085', 2, 'MUNICIPALIDAD DE OREAMUNO', 'MUNICIPALIDAD DE OREAMUNO', NULL, '1950-08-17', NULL, '2147483647', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, 'En la administración de don Alfredo González Flores, el 17 de agosto de 1914, en ley No. 68 se le otorgó el título de Villa al pueblo de San Rafael, cabecera del cantón creado en esa oportunidad. Posteriormente el 6 de diciembre de 1963, en el gobierno de don Francisco Orlich Bolmarcich, se decretó la ley No. 3248, que le confirió a la villa, la categoría de Ciudad.', '', '', '2018-02-07 16:37:12', 'Jose Rivas'),
('304150114', 1, 'Melina Obando Salas', 'Melina Obando Salas', 'cr', '2017-10-21', 1, '1', '0', 10, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '304150114', 'Melina', 'N/R', 1, '0', 'N/R', 'Melina', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-10-21 20:48:30', 'WEB');
INSERT INTO `sis_catalogo_juridicos` (`num_identificacion`, `cod_tipo_identificacion`, `des_razon_social`, `des_nick_name`, `cod_nacionalidad`, `fec_constitucion`, `num_score`, `cod_ejecutivo`, `cod_ejecutivo_backup`, `cod_tipo_membresia`, `num_cuenta_dolares`, `num_cuenta_colones`, `num_cuenta_euros`, `num_cta_colones_ATA`, `num_cta_dolares_ATA`, `num_cc_colones_ATA`, `num_cc_dolares_ATA`, `num_iban_colones_ATA`, `num_iban_dolares_ATA`, `num_cedula_rep_legal`, `des_nombre_rep_legal`, `des_direccion_rep_legal`, `cod_estado_civil_rep_legal`, `des_profesion_rep_legal`, `des_nombre_contacto`, `des_telefono_contacto`, `des_correo_contacto`, `des_direccion_contacto`, `cod_actividad_economica`, `ind_tipo_cliente`, `ind_es_fideicomiso`, `ind_tipo_representante_legal`, `cod_pais`, `cod_provincia`, `cod_canton`, `cod_distrito`, `cod_tipo_sector`, `mon_riesgo_inherente`, `des_logo_cliente`, `des_descripcion`, `des_aux_tipo`, `des_aux_valor`, `fec_creacion`, `cod_usuario_modificacion`) VALUES
('3101005744', 2, 'PURDY MOTOR SOCIEDAD ANONIMA', 'PURDY MOTOR TOYOTA', NULL, '1957-01-08', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/3101005744.png', 'El 8 de enero de 1957, don Xavier Quirós Oreamuno fundó Purdy Motor. En la década de 1950 con la construcción de la carretera Panamericana el Toyota Land Cruiser se convirtió en el mejor aliado de los productores costarricenses, debido a que la mayoría de caminos eran en lastre. A través de los últimos 60 años Purdy Motor se ha consolidado como la principal compañía distribuidora de vehículos en Costa Rica, con sus marcas Toyota, Dahiatsu y Lexus...<a href=\'https://www.toyotacr.com/purdy-historia/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-02-07 21:50:40', 'Francisco Ulate Azofeifa'),
('3101007749', 2, 'REFINADORA COSTARRICENSE DE PETROLEO SOCIEDAD ANONIMA', 'RECOPE', 'CR', '1961-01-01', 0, '2147483647', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '', 0, 0, 0, 1, '0.0000', 'images/recope.png', '1961; Un grupo privado funda RECOPE e inicia gestiones para obtener los permisos del Ministerio de Economía, Industria y Comercio con....... <a href=\'https://www.recope.go.cr/quienes-somos/historia/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', NULL, NULL, '2017-06-16 20:57:30', 'Jose Rivas'),
('3101009059', 2, 'RADIOGRAFICA COSTARRICENSE SOCIEDAD ANONIMA', 'RACSA', NULL, '1964-06-18', NULL, '3101727041', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3101009059.png', 'Por Ley Nº 3293 del 18 de junio de 1964, el ICE y la Compania Radiografica Internacional de Costa Rica formaron una sociedad mixta, a partes iguales, denominada Radiografica Costarricense, S.A. (RACSA), por un plazo social de trece años. Durante la decada de los ochenta, RACSA introdujo al mercado nacional novedosos servicios de telecomunicaciones, como RACSAFAX para la transferencia de información escrita, y RACSAPAC (Red Pública de Datos X.25), tercera de su especie instalada en Latinoamerica, para brindar servicios de comunicacion a nivel nacional y centroamericano. En 1992, la Asamblea Legislativa, con la Ley No.7298, amplio el plazo social de RACSA por 25 años mas. En 1994 RACSA inicio la comercializacion en el pais del servicio Internet. Para conocer en detalle el desarrollo de este servicio en el país.', '', '', '2018-07-10 23:35:11', 'Francisco Ulate Azofeifa'),
('3101011173', 2, 'ROMA PRINCE S.A', 'PASTAS ROMA', 'CR', '1961-01-01', NULL, '2147483647', '', 6, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'images/3101011173_logor', 'En un pequeño local, en el año 1961, la Compañía Pastas Alimenticias Roma, S.A., inició sus actividades con el firme propósito de fabricar las mejores pastas del país. A base de esfuerzos las Pastas Roma fueron introduciéndose en el mercado nacional, y en pocos años llegaron a ser las de más ventas en el país.  En el año 1973, el nombre “Pastas Alimenticias Roma, S.A.”, fue cambiado a “Roma Prince, S.A.”, Aunque los productores siguieron conociéndose como Pastas Roma. El ritmo ascendente de la compañía exigió que en 1976 se trasladara las instalaciones originales en Escazú a un edificio situado en la ciudad de Alajuela.  La gran aceptación y demanda por las Pastas Roma hizo necesario el cambio y modernización del equipo de fabricación. Fue así que en 1987 se tomó la decisión de adquirir la mejor maquinaria para la fabricación de pastas largas, por lo que se importó desde Italia una línea de producción de alta temperatura de la marca Pavan, En ese momento Roma Prince, se convirtió en la', '', '', '2017-11-07 17:26:08', 'Francisco Ulate Azofeifa'),
('3101012009', 2, 'BAC SAN JOSE COSTA RICA S.A.', 'BAC', 'CR', '1952-01-01', 1, '2147483647', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '', 0, 0, 0, 2, '0.0000', 'images/logoBACcredomatic.png', 'Los inicios del Grupo BAC Credomatic se remontan a más de medio siglo atrás, cuando en 1952 se fundó el Banco de América, en Nicaragua. Sin embargo, no fue sino hasta los años setenta cuando se incursionó en el negocio de tarjetas de crédito,  mediante las empresas Credomatic...... <a href=\'https://www.baccredomatic.com/es-cr/nuestra-empresa/historia\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-01-05 16:29:27', 'Rafael Villalobos'),
('31010273496', 2, 'FLORIDA BEBIDAS S.A.', 'FIFCO', 'CRC', '1908-01-01', NULL, '', '', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'gguillen@masterzon.com', NULL, 1, 'X', 'N', 'G', '188', 4, 408, 40803, 2, '0.0000', 'images/fifco.png', 'Florida Ice and Farm Company (FIFCO) naciÃ³ en 1908, en La Florida de Siquirres, provincia de LimÃ³n, Costa Rica. Fue fundada por cuatro hermanos de origen jamaicano de apellidos Lindo Morales, como una empresa dedicada a la agricultura y la fabricaciÃ³n de hielo.\nEn 1912, los hermanos Lindo adquirieron la CervecerÃ­a y RefresquerÃ­a Traube....<a href=\'http://www.florida.co.cr/Historia\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', NULL, NULL, '2016-05-18 00:00:00', 'dba'),
('310103321935', 2, 'MULTI MARKET SERVICES COMMUNICATION COSTA RICA SA', 'MULTI.MARKET', 'CR', '2017-01-01', 1, '1', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'P', '', '', '', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2017-01-27 18:49:52', 'Gerson'),
('3101036581', 2, 'SEGURICENTRO SOCIEDAD ANONIMA.', 'SEGURICENTRO S.A.', 'CR', '2013-10-24', 1, '206440727', '0', 9, '15109110026001718', '15109510010010344', '0', NULL, NULL, NULL, NULL, NULL, NULL, '108790230', 'Sergio Jose Zoch Rojas', 'San Jose, Moravia, La Guaria.  Frente al Colegio San Joseph', 1, 'Ingeniero Industrial', 'Sergio Jose Zoch Rojas', '22568080', 'gguillen@masterzon.com', 'San Jose, Moravia, La Guaria.  Frente al Colegio San Joseph', 1, 'P', 'N', '', 'CR', 1, 1, 1, 2, '0.0000', 'images/seguricentro.png', 'Misión:\r\nComercializar equipos de seguridad de vanguardia, a través de un equipo de trabajo capacitado y motivado para brindar el mejor servicio y asesoría a nuestros clientes...<a href=\'http://www.seguricentro.com/?action=empresa\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2017-11-27 20:38:05', 'Jose Rivas'),
('3101063817', 2, 'Temafra S.A', 'Temafra', 'CR', '2017-05-22', 1, '801070063', '', 2, '15100010026163394', '15100010012080428', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', 'Lisbeth Salguera', '2258-28-07 ext 4510', 'gguillen@masterzon.com', '', 0, 'P', 'N', '', '', 0, 0, 0, 0, '0.0000', NULL, '', '', '', '2017-11-07 22:51:42', 'Francisco Ulate Azofeifa'),
('3101081676', 2, 'AXIOMA INTERNACIONAL S,A, ', 'AXIOMA', 'CR', '1998-01-01', 1, '801070063', '', 9, '10200009119791932', '10200009119787735', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '601820513', 'José Rolando Alvarado Avellán ', 'San José, Central, Uruca, Del Hotel Best Western Irazú, 125 al este', 4, 'INGENIERO ELÉCTRICO, Costarricense, ', 'Oscar Esquetini ', '2290 9243', 'gguillen@masterzon.com', 'San José, Central, Uruca, Del Hotel Best Western Irazú, 125 al este ', 0, 'P', 'N', 'A', 'CR', 1, 1, 7, 2, '0.0000', 'images/axioma.png', 'Axioma tiene más de 20 años de presencia en el mercado nacional. Contamos con amplia experiencia en la administación técnica y construcción de grandes proyectos de integración de tecnologías de transporte de información. Proveemos a nuestros clientes soluciones de comunicaciones con un alto nivel de calidad<a href=\'http://www.axioma.co.cr/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a> ', '', '', '2018-07-12 18:16:19', 'Rafael Villalobos'),
('3101091284', 2, 'Veromatic', 'Veromatic', 'CR', '2018-03-08', 1, '801070063', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '110360450', 'Max', 'N/R', 1, '0', 'N/R', 'Max', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', '', '', '', '2018-02-12 17:41:09', 'Rafael Villalobos'),
('3101098063', 2, 'MULTINEGOCIOS INTERNACIONALES AMERICA S.A.', 'Multiasa', 'CR', '1990-01-01', 3, '801070063', '', 2, '', '15201001016949878', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '107820640', 'Adrián Madrigal Cerdas', 'San José, Santa Ana, Río Oro', 4, 'ADMINISTRACIÓN DE EMPRESA, Costarricense, ', 'Fernando Madrigal Cerdas', '87081812', 'gguillen@masterzon.com', 'San José, Barrio Corazón de Jesús, contiguo a Yanber, Bodegas piso Pisos S.A 11', 0, 'P', 'N', 'A', 'CR', 1, 1, 3, 2, '0.0000', 'images/multiasa.png', 'Actualidad con más de 150 contratos distribuidos en 750 lugares en todo el país, contando con un canal de distribución adecuada, un  cuerpo de supervisión constante y más de 1450 empleados  para poder brindar un excelente servicio a nuestro cliente.<a href=\'http://www.mutiasa.com/index.php\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a> ', NULL, NULL, '2017-06-22 17:09:00', 'Francisco Ulate Azofeifa'),
('3101114047', 2, 'CONSTRUCTORA PRESBERE SA', 'CONSTRUCTORA PRESBERE SA', 'CR', '1991-11-01', 1, '2147483647', '0', 9, '0', '15109610010009100', '0', NULL, NULL, NULL, NULL, NULL, NULL, '112630338', 'Marvin Alberto Oviedo Mora', 'San José,  Aserrí, Barrio María Auxiliadora, 350 metros sureste del taller de buses Mario Morales', 2, 'Empresario', 'Alonso Oviedo Mora', '22304089', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', 'Fundamentada en la producción y colocación de mezcla asfáltica en caliente, tanto para entidades públicas como privadas a nivel nacional.  Con el paso de los años y tras la necesidad de nuestros clientes, se incursionó en otros servicios de infraestructura vial, como lo son movimientos de tierras, alcantarillados sanitarios y pluvial, canalizaciones y otro tipo de pavimentos tales como los rígidos, adoquinados y tratamientos bituminosos superficiales, servicios que brindamos entre otros hasta el día de hoy, incursionando de esta manera, en diferentes áreas de la construcción.', '', '', '2018-02-01 18:51:36', 'Rafael Villalobos'),
('3101117297', 2, 'DISEÑO ARQCONT S.A', 'ARQCONT S.A', 'CR', '1985-04-01', NULL, '801070063', '', 9, '15201001044392601', '15201001044392363', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '601560512', 'FRANCISCO MORA ROJAS', 'Heredia, Ulloa, 400 metros suroeste de la entrada principal del Condominio La Ladera', 2, 'Arquitecto', 'Francisco Mora Rojas', '83836068', 'gguillen@masterzon.com', 'Heredia, Ulloa, 400 metros suroeste de la entrada principal del Condominio La Ladera', NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/3101117297.A', 'Somos una Empresa dedicada a la construccion y consultoria, brindamos sus servicios en el campo de infraestructura (inmobiliario) desde 1985. Nos especializamos en la innovacion de diseño y en la busqueda de alternativas a sistemas constructivos acorde a las exigencias actuales y segun necesidades de los clientes, bajo un estricto respeto por el medio. Cuenta con personal altamente capacitado tanto profesional como tecnico para la realizacion de las labores que ofrece. Nuestra actividad esta respaldada por maquinaria y equipo de ultima generacion y laboratorio especializado con alta tecnologia. Hemos desarrollado a lo largo de estos 25 años proyectos Institucionales con mas de 37.223 m2 y privados con un aproximado 22.500 m2.', '', '', '2018-07-12 18:12:27', 'Rafael Villalobos'),
('3101127663', 2, 'CREACIONES PUBLICITARIAS INTER S.A.', 'CREACIONES', 'CR', '2009-08-20', 1, '801070063', '', 9, '15109110026003114', '15109110010008368', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '109500826', 'Sonia Rodriguez Pérez', 'San José, Tibas, Llorente, 75 mts Este Price Smart  Apartamentos La Macha', 4, 'PUBLICISTA, Costarricense, ', 'Sonia Rodriguez Pérez', '8309-9636', 'gguillen@masterzon.com', 'San José, Vásquez de Coronado, Patalillo, 300 este del Mall Don Pancho ', 0, 'P', 'N', 'A', 'Costa Rica', 1, 11, 4, 2, '0.0000', 'images/logo_creaciones_p.png', 'Agencia de Publicidad y Mercadeo, diseño de experiencias publicitarias BTL y eventos..... <a href=\'https://es-la.facebook.com/pg/creacionespublicitariasCR/about/?ref=page_internal\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-07-12 18:16:44', 'Rafael Villalobos'),
('3101142660', 2, 'New Medical S.A', 'New Medical S.A', 'CR', '2017-09-27', 1, '1', '0', 2, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '106120472', 'Miguel ', 'N/R', 1, '0', 'N/R', 'Miguel ', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-09-27 18:45:00', 'WEB'),
('3101151258', 2, 'Chaso del Valle S.A.', 'Chaso del Valle', 'CR', '2002-03-04', 0, '206440727', '', 6, '11400007910462751', '15114210010000902', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '107830445', 'Francisco Jose Soto Sagot', 'San Jose, Desamparados, San Antonio, Residencial Boulevard casa 31a', 2, 'Comerciante', 'Francisco Soto Sagot', '83813203', 'gguillen@masterzon.com', '', NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, '/images/chaso.png', 'Empresa especializada en el diagnóstico para la calidad e inocuidad de los alimentos desde la granja hasta la mesa y la calidad del agua . Ofrecemos pruebas de diagnóstico de campo, servicio de análisis de laboratorio y plataformas de inspección. Para la mejora y el bienestar de la salud humana, la salud animal y calidad ambiental... <a href=\'https://www.chaso.com/\' alt=\'+info\' target=\"_black\"/><img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2017-12-14 23:03:50', 'Gerson'),
('3101172938', 2, 'CONSTRUCTORA HERMANOS BRENES S.A, ', 'Constructora Brenes', 'CR', '1992-01-01', 1, '206440727', '', 9, '15107510026001058', ' 15107510010082221 ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '3-0197-0458', 'HUGO ERNESTO  BRENES GONZALEZ', 'Cartago, El Guarco, Tejar', 2, 'Empresario, Costarricense, ', 'Maricruz Montero', '40017355', 'gguillen@masterzon.com', 'Cartago, El Guarco, Zona Industrial', 0, 'P', '', 'A', 'CR', 3, 1, 2, 2, '0.0000', 'images/hnos_brenes.jpg', 'Alquiler de maquinaria pesada, construcción de caminos, carreteras, puentes, canales de drenaje en todo tipo de terreno, así como construcción de infraestructura para proyectos urbanísticos ... <a href=\'https://es-es.facebook.com/Constructora-Hermanos-Brenes-124466530924720\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-06-07 21:39:28', 'Gerson'),
('3101176555', 1, 'HOSPITAL SAN JOSE SOCIEDAD ANONIMA', 'HOSPITAL CIMA', 'CR', '1994-05-01', 2, '2147483647', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'S', '', '', '', 0, 0, 0, 2, '0.0000', 'images/cima.png', 'La idea inicial fue construir un hogar especializado en la atenciÃ³n de personas mayores; sin embargo, la iniciativa evolucionÃ³ hasta convertirse en el centro de especialidades mÃ©dicas con mayor proyecciÃ³n en la regiÃ³n: El Hospital CIMA San JosÃ©....... <a href=\'http://cimaweb.azurewebsites.net/quienes-somos/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', NULL, NULL, '2017-05-19 20:11:44', 'Jose Rivas'),
('3101200102', 2, 'CONSTRUCCIONES PENARANDA SOCIEDAD ANONIMA', 'CONSTRUCTORA PENARANDA S.A', 'CR', '1997-02-01', NULL, '2147483647', '', 9, '', '15102010010046521', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '401500070', 'Marco Penaranda Chinchilla', 'San Ramón, Alajuela', 2, 'Ingeniero', 'Jose Cuadra Arroyo', '24450254', 'gguillen@masterzon.com', 'San Ramón, Alajuela', NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/3101200102.png', 'CONSTRUCCIONES PENARANDA S.A, fundada en 1997, es una empresa constructora enfocada a la Remodelación y Construcción de Obras Civiles, así como el alquiler de maquinaria: Vagonetas y Back Hoe, entre otros. Uno de los principales objetivos de la empresa es hacer de la construcción una actividad productiva de la mejor calidad, alcanzando los mejores resultados técnicos y económicos', '', '', '2018-02-20 20:03:00', 'Francisco Ulate Azofeifa'),
('3101203019', 2, 'CONSTRUCTORA Y CONSULTORA WIND Y ASOCIADOS, S.A. ', 'WIND_S.A.', 'CR', '2016-11-30', 1, '1', '', 2, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Ernesto Wind Barroca', 'Curridabat, Granadilla', 1, NULL, NULL, NULL, 'gguillen@masterzon.com', NULL, NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2016-11-30 08:17:34', 'gerson78'),
('3101213117', 2, 'COMANDOS DE SEGURIDAD UNIVERSAL S.A', 'SEGURIDAD DELTA', 'CR', '2017-04-19', 1, '801070063', '', 2, '', '15100010011579953', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', 'Jesenia Morales', '4035-2135', 'gguillen@masterzon.com', '', 0, 'P', '', '', '188', 1, 1, 1, 2, '1.0000', NULL, NULL, NULL, NULL, '2017-05-09 15:43:08', 'Jose Rivas'),
('3101220952', 2, 'KANI MIL NOVECIENTOS UNO SOCIEDAD ANONIMA', 'KANI', 'Costa Rica', '2003-02-01', 1, '1', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1-0789-0344', 'JOSE ALBERTO OLLER ALPIREZ', 'SAN PEDRO DE MONTES DE OCA', 2, 'ADMINISTRACIÓN DE EMPRESA, Costarricense, ', 'FLORIA LIZ SALAZAR VARGAS', '25370102', 'gguillen@masterzon.com', '', 0, 'X', '', 'A', 'Costa Rica', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2017-01-24 14:59:31', 'Jose Rivas'),
('3101223757', 2, 'CORPORACION CENELEC S.A', 'Cenelec', 'CR', '2008-08-01', 1, '801070063', '', 9, '15201001028736567', '15201001025012283', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '503040109', 'Allan Pineda Obando', 'Heredia, San Pablo', 2, 'Comerciante, Costarricense, ', 'Cristel López', '22222626', 'gguillen@masterzon.com', 'San José, Central, Plaza Víquez, Diagonal a la entrada a las piscinas', 0, 'P', '', 'A', 'Costa Rica', 1, 1, 4, 2, '0.0000', 'images/cenelec.jpg', 'Empresa con 15 aÃ±os de trayectoria. Nos dedicamos a brindar servicios en las Ã¡reas de LÃ­nea Blanca, LÃ­nea MarrÃ³n y Aires AcondicionadosSomos una empresa con mas de 15 aÃ±os de trayectoria, dedicada a la ReparaciÃ³n de electrodomÃ©sticos, Venta, InstalaciÃ³n y reparaciÃ³n de Aires Acondicionados, ademÃ¡s de la venta de repuestos originales de las marcas LG, Whirlpool, Panasonic, Sony, Starlight, Toolcraft y muchas mas. <a href=\'http://www.grupocenelec.com\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a> ', '', '', '2018-07-12 18:18:50', 'Rafael Villalobos'),
('3101225198', 2, 'CONSTRUCTORA CONTEK S.A', 'CONTEK S.A', 'CR', '1998-05-19', NULL, '206440727', '', 9, '11400007811152664', '11400007011229188', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '108010458', 'Óscar Marín Zamora', 'Residencial Loma Verde, Curridabat, San José', 2, 'Ingeniero Civil', 'Óscar Marín Zamora', '60593251', 'gguillen@masterzon.com', '100 este y 100 sur del BNCR, Curridabat', NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/3101225198.png', 'Somos una empresa constructora especializada en construcción de condominios, casas de habitación y edificios. Experiencia en proyectos de participación pública • Renovación de varias sedes del Banco Nacional...<a href=\'http://contekcr.com/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-07-16 20:37:00', 'Francisco Ulate Azofeifa'),
('3101235381', 2, 'NOVUS MENSAJERIA S.A.', 'NOVUS', 'CR', '2004-10-03', 2, '206440727', '', 9, '', '10200009049894071', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '700700101', 'LUBADINIA LEON MARENCO', 'San Vicente ,Santo Domingo, Heredia', 4, 'Administradora, Costarricense, ', 'Criss Mora', '22906611 Ext. 105', 'gguillen@masterzon.com', 'San José, Central, Sabana Norte, del Banco Improsa 100 norte 50 oeste y 175 norte', 0, 'P', '', 'A', 'CR', 1, 1, 8, 2, '0.0000', 'images/novus.png', 'Empresa especializada en brindar servicios de entrega de documentación y paquetería en todo el territorio nacional. Nuestra promesa de valor es la entrega en un tiempo máximo de 24 horas. <a href=\'http://novuscr.com/ \' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:23:08', 'Jose Rivas'),
('3101254525', 2, 'ESTRUCONSULT SOCIEDAD ANONIMA', 'ESTRUCONSULT S.A', 'CR', '1999-10-04', NULL, '3101727041', '', 12, '15109210026003391', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '106690153', 'Orlando Gei Brealey', 'Pozos de Santa Ana, San Jose', 2, 'Ingeniero Civil', 'Orlando Gei Brealey', '83844479', 'gguillen@masterzon.com', 'Pozos de Santa Ana, San Jose', NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/LOGO-ESTRUCONSULT.png', 'EstruConsult S.A es una empresa costarricense, esta constituida por un grupo de profesionales con especialidad en las areas de Ingenieria civil y estructural. El grupo posee amplia experiencia profesional en la region centroamericana, complementada con trayectoria academica en prestigiosas universidades.', '', '', '2018-06-20 14:59:04', 'Francisco Ulate Azofeifa'),
('3101260434', 2, 'HAMBURG SUD COSTA RICA SOCIEDAD ANONIMA', 'HAMBURG SUD', 'Costa Rica', '2009-01-01', 1, '801070063', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', 'Marcus Fred. Brusius', 'Escazú Corporate Center, Piso 7, SJ, CR', 2, '', 'Maria Rivera', '25193314', 'gguillen@masterzon.com', 'Escazú Corporate Center, Piso 7, SJ, CR', 0, 'X', '', '', '1', 1, 1, 1, 2, '1.0000', 'images/hamburg_sud.png', '1871: FundaciÃ³n de la Hamburg SÃ¼damerikanische Dampfschifffahrts-Gesellschaft como sociedad anÃ³nima, por once representantes de casas de comercio de Hamburgo. Tres buques con casi 4.000 TRB realizan un servicio de lÃ­nea mensual a Brasil......... <a href=\'https://www.hamburgsud.com/group/es/corporatehome/company/history/index.html\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', NULL, NULL, '2017-05-18 22:44:33', 'Gerson'),
('3101265330', 2, 'XISA Constructora SA', 'XISA', 'CR', '2017-06-27', 1, '2147483647', '0', 6, '15123810020000549', '15105410010012882', '0', NULL, NULL, NULL, NULL, NULL, NULL, '302870479', 'Erick Brenes Vasquez', 'Cartago, del servicentro el Guarco 100 metros sur y 50 metros oeste', 1, 'Administrador, Costarricense, ', 'Erick Brenes Vasquez', '25720973', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 2, '0.0000', '', NULL, NULL, NULL, '2017-06-27 21:32:43', 'Gerson'),
('3101295868', 2, 'DISTRIBUIDORA LA FLORIDA SOCIEDAD ANONIMA', 'FIFCO', 'CR', '2001-05-24', NULL, '', '', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'gguillen@masterzon.com', NULL, 1, 'P', 'N', 'G', 'IND', 4, 408, 40803, 1, '2.8000', 'images/fifco.png', 'Florida Ice and Farm Company (FIFCO) naciÃ³ en 1908, en La Florida de Siquirres, provincia de LimÃ³n, Costa Rica. Fue fundada por cuatro hermanos de origen jamaicano de apellidos Lindo Morales, como una empresa dedicada a la agricultura y la fabricaciÃ³n de hielo.En 1912, los hermanos Lindo adquirieron la CervecerÃ­a y RefresquerÃ­a Traube....<a href=\'http://www.florida.co.cr/Historia\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', NULL, NULL, '2016-05-18 00:00:00', 'dba'),
('3101300763', 2, 'Distribuidora de Frutas, Carnes y Verduras Tres M,S.A.', 'Distribuidora de Frutas, Carnes y Verduras Tres M,', 'CR', '2018-02-15', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '107510294', 'Carlos', 'N/R', 1, '0', 'N/R', 'Carlos', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-02-15 09:54:28', 'WEB'),
('3101314088', 2, 'AGREGADOS H Y M SOCIEDAD ANONIMA', 'AGREGADOS H Y M', 'CR', '1978-01-01', 1, '2147483647', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'P', 'N', 'A', 'CR', 0, 0, 0, 2, '0.0000', 'images/agregados_hym.jpg', 'Desde el 2013 H&M enfoca su crecimiento en el concreto premezclado, ampliando operaciones en Guanacaste y posteriormente en el Coyol de Alajuela, con dos modernas plantas de concreto y bombas telescópicas. Además se adquirió una planta móvil para servir proyectos masivos en sitios alejados.\n\nHoy contamos con cuatro centros de producción y distribución en Costa Rica: Santa Clara (oficinas centrales) y San Josecito en San Carlos y más recientemente Península de Papagayo en Guanacaste y Coyol de Alajuela, donde le esperamos para que conozca las mejores plantas de producción tanto de concreto como de agregados y la moderna y eficiente flotilla de equipo pesado, pero sobre todo el gran equipo humano que nos colabora... <a href=\'http://www.grupohym.com\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', NULL, NULL, '2017-06-26 16:47:18', 'Jose Rivas'),
('3101316814', 2, 'GRUPO OROSI S.A.', 'GRUPO OROSI S.A.', 'CR', '2005-05-31', 1, '206440727', '0', 9, 'CR38015123810020000118', 'CR24015105410010004761', '0', NULL, NULL, NULL, NULL, NULL, NULL, '301971312', 'ELADIO ARAYA MENA', 'Cartago, Agua Caliente 500 metros de la Iglesia', 2, 'Empresario', 'KATTIA ARAYA MARTINEZ', '22595895', 'gguillen@masterzon.com', 'CURRIDABAT', 1, 'P', 'N', '', 'CR', 1, 1, 1, 2, '0.0000', 'images/orosi_ico.png', 'Nuestra Organización se dedica a la construcción de obras de infraestructura y de ingeniería civil. Nos especializamos en ofrecer a nuestros clientes soluciones integrales, desde movimientos de tierra y “agregados de calidad Orosi”, hasta la gestión de proyectos exitosos. Administramos con excelencia obras y proyectos sin distinción de tamaño; nuestro trabajo es preciso y el servicio nuestra vocación. Cuenta con certificación ISO 9001.... <a href=\'http://orosicr.com/quienes-somos.html\' target=\'_black\' alt=\'+info\' height=\"25\" width=\"25\"/>(+ info)</a>', '', '', '2018-06-25 23:14:01', 'Francisco Ulate Azofeifa'),
('3101320803', 2, 'JCB CONSTRUCTORA Y ALQUILER S.A.', 'JCB', 'CR', '2004-01-01', 4, '801070063', '', 6, '', '15100610010054393', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '110370745', 'JUAN CARLOS BOLAÑOS ROJAS', 'GUACHIPELIN DE ESCAZU, SAN JOSE', 2, 'EMPRESARIO, Costarricense, ', '', '22960082', 'gguillen@masterzon.com', '', 0, 'P', '', 'A', 'CR', 0, 0, 0, 2, '0.0000', NULL, '', '', '', '2018-03-14 22:47:22', 'Francisco Ulate Azofeifa'),
('3101376814', 2, 'ADC MOVIL CRI S.A.', 'ADC MOVIL', 'CR', '2004-07-23', 1, '801070063', '', 2, '10700000000091445', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '108090970', 'RODOLFO SOJO GUEVARA', 'San José, Central, Mata Redonda, 400 metros sur del AM PM', 2, 'INFORMATICO, Costarricense, ', 'ORLANDO SOLIS', '22317275', 'gguillen@masterzon.com', 'OFICENTRO LA SABANA EDIFICIO 2  PISO 2', 0, 'P', 'N', 'A', 'CR', 1, 1, 8, 2, '0.0000', 'images/adc_movil.png', 'ADC Movil es una companÌa fundada en el año 2004, dedicada a integrar Soluciones TecnoloÌgicas (software, hardware y networking) especializadas, para la RecoleccioÌn ElectroÌnica de datos dirigidas a empresas y organizaciones puÌblicas o privadas independientemente de su giro de negocios.\n<a href=\'http://adcmovil.com/v2/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a> ', NULL, NULL, '2017-06-22 16:35:45', 'Francisco Ulate Azofeifa'),
('3101383592', 2, 'INMOBILIARIA BERLIZ SOCIEDAD ANONIMA', 'INMOBILIARIA BERLIZ S.A', 'CR', '2012-07-10', NULL, '3101727041', '', 9, '', '16100014104489993', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '108200490', 'BERNAL AGUILAR CORDERO', 'Alajuela, Grecia, Santa Gertrudis Norte', 2, 'Ingeniero', 'Bernal Aguilar Cordero', '24443609', 'gguillen@masterzon.com', 'Alajuela, Grecia, Santa Gertrudis Norte, de la escuela 150 sur y 125 suroeste', NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, 'Somos una empresa de capital costarricense, nos enfocamos en las areas de construccion y mantenimiento. Hemos desarrollado proyectos para el Gobierno Central, ICE, Municipalidad de Alajuela, RACSA, entre otras entidades del gobierno de Costa Rica. Nos caracterizamos por el excelente servicio y el cumplimiento de los mejores estandares de calidad.', '', '', '2018-07-10 23:17:12', 'Francisco Ulate Azofeifa'),
('3101384104', 2, 'INVERSIONES NATURARZA', 'NATURARZA', 'CR', '2017-05-05', 1, '2147483647', '', 2, 'CC11400007455416931', 'CC11400007355420811', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', 'ARACELI VALVERDE', '86722772', 'gguillen@masterzon.com', '1', 1, 'P', 'N', '', '1', 1, 1, 1, 1, '1.0000', NULL, NULL, NULL, NULL, '2017-05-05 20:28:51', 'Gerson'),
('3101393948', 2, 'Agrileasing Latinoamericano S. A.', 'Agrileasing Latinoamericano S. A.', 'CR', '2017-08-17', 1, '1', '0', 2, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '132000085615', 'Alejandro', 'N/R', 1, '0', 'N/R', 'Alejandro', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-08-17 14:32:37', 'WEB'),
('3101395022', 2, 'Inversiones Colmetex', 'Inversiones Colmetex', 'CR', '2018-07-12', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '2663147', 'Daniela ', 'N/R', 1, '0', 'N/R', 'Daniela ', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-07-12 15:27:23', 'WEB'),
('31014036495', 2, 'PRO IN MSA SOCIEDAD ANONIMA', 'PRO IN MSA', 'CR', '1980-02-01', 1, '2147483647', '', 6, '74010220405146', '74010210405145', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 2, 'EMPRESARIO', '', '', 'gguillen@masterzon.com', 'HEREDIA, San Anotnio de Belen', 0, 'P', '', '', '', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2017-07-27 18:06:34', 'Gerson'),
('3101417130', 2, 'Servicios Hospitalarios Latinoamericanos Integrados (S.H.L.I.) ', 'Hospital La Catolica', NULL, '1963-03-16', NULL, '801070063', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '22463000', 'gguillen@masterzon.com', 'San Antonio de Guadalupe, Goicoechea, Costa Rica, frente a los Tribunales de Justicia.', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/3101417130.png', 'Hospital La Católica abrió sus puertas el 16 de marzo de 1963 como una nueva alternativa en la medicina privada. Esta iniciativa estuvo a cargo de un grupo de religiosas de la Congregación Hermanas Franciscanas de la Purísima Concepción y médicos, identificados con el bienestar de los costarricenses. Con el pasar del tiempo el Hospital se distinguió por su atención única y compromiso con la salud y la vida de cada uno de sus pacientes. Somos un hospital que contribuye a MEJORAR LA CALIDAD DE VIDA DE NUESTROS PACIENTES, con los más ALTOS ESTÁNDARES de excelencia.', '', '', '2018-02-22 17:28:04', 'Rafael Villalobos'),
('3101439852', 2, 'LG SERVICIOS ESPECIALIZADOS S.A.', 'LG', 'CR', '2006-05-05', 1, '206440727', '', 9, '15118420020024979', '15118420010136677', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '5-0304-0109', 'Allan Eddie Pineda Obando', 'Heredia, San Pablo', 2, 'Comerciante, Costarricense, ', 'Cristel López', '22222626', 'gguillen@masterzon.com', 'San José, Central, Plaza Víquez, Diagonal a la entrada a las piscinas', 0, 'P', '', 'A', 'CR', 1, 1, 4, 2, '0.0000', 'images/LG.png', 'DIRECCION: Plaza Viquez, 200 Norte de la Ferreteria el Pipiolo, San Jose.  <a href=\'https://www.facebook.com/Taller-de-Servicio-Autorizado-LG-Costa-Rica-1656629054620826/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-07-12 18:18:14', 'Rafael Villalobos'),
('310146536', 2, 'SCOTIABANK DE COSTA RICA S.A', 'SCOTIABANK', NULL, '1995-01-04', NULL, '801070063', '', 6, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1729973', 'MANFRED ANTONIO SAENZ MONTERO', '', 2, 'LICENCIADO EN DERECHO', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/scotia_ico.png', '\r\nEl Grupo BNS de Costa Rica es una subsidiaria de The Bank of Nova Scotia. Ingresó a Costa Rica en 1995 ofreciendo al mercado nacional una amplia gama de productos y servicios financieros en sectores de Banca de Personas, Banca Comercial y Corporativa, Pymes, además de Fondos de Inversiones, Leasing, Seguros y Banca Privada ... <a href=\'http://www.scotiabankcr.com/Acerca/Quienes-somos/Perfil-corporativo/scotiabank-en-costa-rica.aspx\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', NULL, NULL, '2017-08-31 23:21:04', 'Gerson'),
('3101472019', 2, 'Servicios integrados aduanales shekina s.a', 'Servicios integrados aduanales shekina s.a', 'CR', '2018-06-27', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '203920483', 'JUANCARLOS ', 'N/R', 1, '0', 'N/R', 'JUANCARLOS ', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-06-27 15:51:03', 'WEB'),
('3101485552', 2, 'ROCK CONSTRUCTIONS AND DEVELOPMENT SOCIEDAD ANONIMA', 'ROCK CONSTRUCTIONS S.A', 'CR', '2001-07-02', NULL, '3101727041', '', 9, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '109780599', 'RICARDO LIZANO YGLESIAS', 'San José, Santa Ana', 2, 'Ingeniero Civil', 'Ricardo Lizano Yglesias', '25887900', 'gguillen@masterzon.com', 'San José, Santa Ana, del Más x Menos 200 norte y 50 este', NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/3101485552.jpg', 'Somos una empresa constructora especializada en obras de infraestructura residencial y turistica de gran envergadura, tales como proyectos inmobiliarios y urbanizacion en general, los cuales se estan desarrollando actualmente a lo largo y ancho de Costa Rica.  Desde comienzos hemos sobrepasado nuestras expectativas como lideres en la construccion. Buscar el mejoramiento en la calidad de los productos y servicios que ofrecemos. Asi como una constante innovacion en nuevas practicas y sistemas en la construccion.', '', '', '2018-07-11 22:12:27', 'Francisco Ulate Azofeifa'),
('3101493379', 2, 'INVERSIONES MADRIQUE SOCIEDAD ANONIMA', 'INVERSIONES MADRIQUE S.A', 'CR', '2010-07-19', NULL, '3101727041', '', 9, '', '16101008310189489', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '303560702', 'LUIS DIEGO QUESADA MADRIGAL', 'Barrio Asís, Cartago', 4, 'Economista', 'Luis Diego Quesada Madrigal', '70705222', 'gguillen@masterzon.com', 'Barrio Asís, Cartago', NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/3101493379.jpg', 'Inversiones Madrique S.A es una empresa costarricense que se dedica al negocio inmobiliario, con la administración y alquiler de edificios a diferentes instituciones.', '', '', '2018-07-18 21:55:44', 'Francisco Ulate Azofeifa'),
('3101511598', 2, 'Asesores Sysynfo S.A', 'Asesores Sysynfo S.A', 'cr', '2018-02-28', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '106540792', 'Gerardo Antonio', 'N/R', 1, '0', 'N/R', 'Gerardo Antonio', 'gguillen@masterzon.com', 'N/R', 1, 'N', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-02-28 08:36:40', 'WEB'),
('3101526083', 1, 'INVERSIONES TIERRA NUESTRA DEL SOL  K Y M S.A.', 'TierraSOL', 'CR', '2017-03-01', 1, '1', '', 2, '12300130007065011', '12300130007065005', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1-1008-0199', 'MANUEL CASTRO SANCHEZ', 'HEREDIA , SAN RAFAEL CALLE COLIBRI', 2, 'ADMINISTRACIÓN DE EMPRESA, Costarricense, ', 'WALTER ESPINOZA', '8821-5561', 'gguillen@masterzon.com', '', 0, 'N', 'N', 'A', 'Costa Rica', 0, 0, 0, 0, '1.0000', NULL, NULL, NULL, NULL, '2017-01-24 18:40:49', 'Gerson'),
('3101560550', 2, 'FLAMA AZUL DEL OESTE, S.A.', 'Flama_Azul', 'CR', '2016-11-01', 1, '1', '', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'gguillen@masterzon.com', NULL, NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2016-11-25 13:45:18', 'gerson78'),
('3101562914', 2, 'RIVERING DE COSTA RICA S.A', 'RIVERING S.A', 'CR', '2009-01-29', 0, '2147483647', '', 9, '', '15201001027259674', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1-0811-0682', 'Julio Masís Jiménez', 'San José', 2, 'Ingeniero', 'Marisol Masís Jiménez', '2227-0631', 'gguillen@masterzon.com', 'Barrio Los Sauces, San Francisco de Dos Ríos, San José', 1, 'P', NULL, NULL, NULL, NULL, NULL, NULL, 2, '0.0000', 'images/rivering.jpeg', 'Consultoría en el Área de la Ingeniería Civil y Ambiental. Especializados en las áreas de Diseño hidráulico e hidrológico de carreteras y puentes, diseño de sistemas de alcantarillados pluviales y sanitarios, diseño de sistemas de abastecimiento de agua potable (acueductos) , diseño de obras de protección contra inundaciones, diseño de obras de protección contra la erosión, diseño de obras de protección contra deslizamientos y avalanchas de lodos.  Además de estudios de vulnerabilidad y amenaza de origen hidrometeorológico, mapeo de zonas inundables. Desarrollamos estudios para protocolos de hidrología de SETENA, estudios de hidrología e hidráulica para permisos de desfogues y peritajes relacionados con hidrología, hidráulica, transporte de sedimentos y mecánica fluvial.', '', '', '2018-03-06 21:15:56', 'Francisco Ulate Azofeifa'),
('3101586136', 2, 'AUTO LAVADO LA PLAYA S.A ', 'AUTO LAVADO LA PLAYA S.A ', 'CR', '2018-07-09', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '503100082', 'GERARDO  ', 'N/R', 1, '0', 'N/R', 'GERARDO  ', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-07-09 08:01:34', 'WEB'),
('3101593688', 2, 'PapelDeco SA', 'PapelDeco', 'CR', '2010-01-11', 2, '801070063', '', 9, '', '15121110010000511', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1-1117-0611', 'Leonel Arturo González Higaldo', 'Heredia, Belén, La Asunción', 2, 'Comerciante, Costarricense, ', 'Marilyn Morales', '22391026', 'gguillen@masterzon.com', 'Heredia, Belén, La Asunción, Frente al Salón del Reino de los Testigos de Jehová', 0, 'P', '', '', '1', 4, 7, 3, 2, '1.0000', 'images/papeldeco.jpg', 'CompaNia que presenta una alternativa de soluciÃ³n a los requerimientos de las empresas, encargÃ¡ndonos de sus necesidades en suministros de limpieza e higiene, empaques flexibles y productos de papel en general de forma integral. <a href=\'http://papeldecocr.com/cms\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-07-12 18:19:48', 'Rafael Villalobos'),
('3101595167', 2, 'Signature South Consulting Costa Rica S.A.', 'Signature South Consulting Costa Rica S.A.', 'CR', '2018-03-22', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '111070740', 'Sergio ', 'N/R', 1, '0', 'N/R', 'Sergio ', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-03-22 11:51:09', 'WEB'),
('3101615701', 2, 'SPINE CR S.A', 'SPINE', 'CR', '2010-02-05', 2, '801070063', '', 9, '15116420025023282', '15116420010048431', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '8-0093-0430', 'María Isabel Reyes Alvarez', 'San, José, Central, Hospital, del BCR 150 norte 100 este y 50 sur,', 4, 'Administradora de Negocios, Costarricense, ', 'María Isabel Reyes Alvarez', '88679323', 'gguillen@masterzon.com', 'San, José, Central, Hospital, del BCR 150 norte 100 este y 50 sur', 0, 'P', 'N', 'A', '1', 1, 1, 3, 2, '0.0000', 'images/spine_cr.png', 'Empresa que innova, diseña, fabrica y comercializa implantes e instrumental de uso quirúrgico para el tratamiento de patologías de columna vertebral.', '', '', '2018-07-12 18:08:36', 'Rafael Villalobos'),
('3101624816', 2, 'Servicios Administrativos e inmobiliarios J y H sociedad anonima', 'Inmob_JyH', 'CR', '2010-12-07', 1, '1', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1-1000-0050', 'Jeffry Gerardo Hernandez Corrales', 'San Jose', 1, '', '', '87127132', 'gguillen@masterzon.com', '', 0, 'P', 'N', '', '', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2016-12-07 16:49:35', 'Jose Rivas'),
('310164051', 2, 'THE BANK OF NOVA SCOTIA CR S.A', 'BNS', NULL, '1921-02-01', NULL, '2147483647', '', 6, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '11004219', 'JUAN CARLOS VEGA VEGA', 'San Jose Uruca ', 2, 'ADMINISTRACIÓN DE EMPRESAS', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/scotia_ico.png', 'El Grupo BNS de Costa Rica es una subsidiaria de The Bank of Nova Scotia. Ingresó a Costa Rica en 1995 ofreciendo al mercado nacional una amplia gama de productos y servicios financieros en sectores de Banca de Personas, Banca Comercial y Corporativa, Pymes, además de Fondos de Inversiones, Leasing, Seguros y Banca Privada ... <a href=\'http://www.scotiabank.com/ca/en/0,1091,5,00.html\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-01-05 16:30:48', 'Rafael Villalobos'),
('3101655669', 2, 'Excelencia en Servicios IT y Outsourcing', 'Excelencia en Servicios IT y Outsourcing', 'CR', '2018-06-24', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '204770156', 'Erick', 'N/R', 1, '0', 'N/R', 'Erick', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-06-24 15:45:06', 'WEB'),
('3101670939', 2, 'V-Net Comunicaciones S.A.', 'V-NET', 'CR', '2014-05-15', NULL, '801070063', '', 9, '15111910020001925', '15111920010029671', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '186200221426', 'Jose Alejandro Hernandez Contreras', 'Condominio Fuerte Ventura casa #49, Pozos Santa Ana', 2, 'Geologo', '', '', 'gguillen@masterzon.com', '', NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, '\\images\\ico_vnet.jpg', 'Empresa dedicada a la distribución de productos de telecomunicaciones en Costa Rica. Distribuidor y comercializador de los productos y servicios de kölbi CR. <a href=\'https://v-netcom.com/inicio/\' target=\'black\'> ( + info ) </a>', '', '', '2018-05-28 17:59:22', 'Jose Rivas'),
('3101677940', 2, 'BROKERS CAPITAL CONSULTORES FINANCIEROS S.A.\r\n', 'BROKERS CAPITAL', 'CR', '2014-02-26', 1, '3101727041', '1', 9, '0', '15201001031215429', '0', '0', '0', '0', '0', '0', '0', '206440727', 'Jose Rivas Ramirez\r\n', 'San Jose , Alajuelita , San Felipe\r\n', 2, 'Administración de Empresas', 'Jose Rivas\r\n', '89100542', 'jrivas@brokerscapitalcr.com\r\n', 'San Jose , Alajuelita , San Felipe\r\n', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, 'images/3101677940.png', 'Brokers Capital Consultores Financieros S.A, es un...\r\n', NULL, NULL, '2018-11-07 17:27:16', 'gerson78'),
('3101690116', 2, 'Sinocem Costa Rica SA', 'Sinocem', 'CR', '2014-12-02', 1, '801070063', '', 6, 'CR66015118910020004127', 'CR87015118910010004698', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '205020049', 'Javier Rojas Segura', 'Alajuela, Grecia, 50 MTRS Oeste del Balneario Tropical', 2, 'Administrador de empresas, Costarricense, ', 'Mario Cortes', '22960082', 'gguillen@masterzon.com', '', 1, 'P', '', '', '188', 1, 1, 1, 2, '1.0000', NULL, '', '', '', '2018-03-14 22:47:53', 'Francisco Ulate Azofeifa'),
('3101697399', 2, 'PROCONSA DE CONCRETO PROYECTOS CONSTRUCTIVOS JB SOCIEDAD ANONIMA', 'CONSTRUCTORA PROCONSA', 'CR', '2015-02-03', 1, '2147483647', '0', 9, '10200009240425670', '10200009240425598', '0', NULL, NULL, NULL, NULL, NULL, NULL, '108790951', 'Ana Marcela Rodriguez Gonzalez', 'Condominio Río Palma  FF 63, Guachípelin, Escazú, San José', 4, 'Politóloga-Economista', 'Ana Marcela Rodriguez Gonzalez', '88540710', 'gguillen@masterzon.com', 'Condominio Río Palma  FF 63, Guachípelin, Escazú, San José', 1, 'P', 'N', '', 'CR', 1, 1, 1, 2, '0.0000', 'images/Proconsa logo.png', 'Proconsa S.A es una empresa de capital costarricense y cuenta con la experiencia comprobada en el sector de construcción de su equipo de ingenieros y técnicos, nuestros servicios están dirigidos al diseño y desarrollo de obras de construcción a nivel público y privado, residencias de medio y alto valor, remodelaciones, servicios de mantenimiento, obras exteriores y edificios.', '', '', '2018-01-03 23:04:11', 'Francisco Ulate Azofeifa'),
('3101701112', 2, 'ARMADILLO DISEÑO Y BTL S.A.', 'ARMADILLO', 'CR', '2016-10-03', 1, '1', '', 2, '', '10200009243868735', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '8-0096-0844', 'MARITZA ORGANISTA DIAZ', 'MORAVIA DE TACOBELL 200OESTE 100 NORTE Y 100 OESTO', 1, 'PUBLICISTA, Costarricense, ', 'MARITZA ORGANISTA', '70104207', 'gguillen@masterzon.com', 'moravia', 0, 'P', '', 'A', 'Costa Rica', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2017-01-27 22:09:47', 'Jose Rivas'),
('3101702806', 2, 'PROPALLET, S.A.', 'PROPALLET, S.A.', 'CR', '2015-07-17', 1, '2147483647', '0', 9, '', '15103620010490148', '0', NULL, NULL, NULL, NULL, NULL, NULL, '111270525', 'Giovanni Rojas Vargas', 'De la Iglesia católica 500 este, casa de dos plantas color amarillo, San  Rafael, Vásquez de Coronado, San José', 2, 'Comerciante', 'Randall Calvo Meléndez', '8322-7786', 'gguillen@masterzon.com', 'Río Segundo de Alajuela, antigua casa Phillipson', 1, 'P', 'N', '', 'CR', 1, 1, 1, 2, '0.0000', '', 'Por más de 20 años ProPallet S.A. ha fabricado tarimas de madera y “Kits” los cuales son todas las partes que posee una tarima pero estas tienen la particularidad que se venden por separado y la empresa o cliente que las adquiera deben de armar las tarimas por ellos mismos. ', '', '', '2018-03-05 22:04:44', 'Francisco Ulate Azofeifa'),
('3101710584', 2, 'HCG COSTA RICA S.A', 'HCG', 'CR', '2017-08-02', NULL, '2147483647', '', 6, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '11111111', 'Mario berrenechea', 'San jose', 2, 'Administración ', '', '', 'gguillen@masterzon.com', '', NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2017-08-18 19:12:12', 'Jose Rivas'),
('3101714710', 2, 'PARQUE INDUSTRIAL DE ZONA FRANCA CITY PLACE SOCIEDAD ANONIMA', 'CITY PLACE', 'CR', '2013-11-01', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'P', '', '', '', 0, 0, 0, 2, '0.0000', 'images/citiplace_logo.png', 'City Place es uno de los desarrollos más innovadores de Rocca Portafolio Comercial. Corresponde al primer Town Center en Santa Ana, un proyecto urbano realmente contemporáneo...  <a href=\'http://www.cityplacecr.com/ \' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:34:55', 'Francisco Ulate Azofeifa'),
('3101714776', 2, 'Princesadulce s.a', 'Princesadulce s.a', 'CR', '2018-06-23', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '109230768', 'Ricardo ', 'N/R', 1, '0', 'N/R', 'Ricardo ', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-06-23 21:17:37', 'WEB'),
('3101719704', 2, 'EQUIPOS TACTICOS Y DE RESCATE ETR S.A', 'EQUIPOS TACTICOS Y DE RESCATE', 'CR', '2017-10-29', 1, '206440727', '0', 9, '', '10200009290931510', '0', NULL, NULL, NULL, NULL, NULL, NULL, '109540130', 'Roy Enrique Cantillano González', 'Lomas de Ayarco, Curridabat, San José', 2, 'Empresario', 'Roy Cantillano', '88923613', 'gguillen@masterzon.com', 'Merced, Central, San José. Calle 14, Avenida 8 y 10, 75 sur del Hospital Metropolitano', 1, 'P', 'N', '', 'CR', 1, 1, 1, 2, '0.0000', '', 'Contamos con 11 años de experiencia en la importación de equipos de rescate, seguridad, herramientas para limpieza y ornato municipal así como camiones y todo lo que conlleva el mantenimiento de parques, jardines e instituciones gubernamentales y privadas para lo cual brindamos la asesoría y servicio en el campo comprometidos con el desarrollo ambiental y social de las zonas que impactamos con el afán de lograr el embellecimiento visual y estético sin comprometer la naturaleza.', '', '', '2018-01-18 16:32:55', 'Elio Rojas Rojas');
INSERT INTO `sis_catalogo_juridicos` (`num_identificacion`, `cod_tipo_identificacion`, `des_razon_social`, `des_nick_name`, `cod_nacionalidad`, `fec_constitucion`, `num_score`, `cod_ejecutivo`, `cod_ejecutivo_backup`, `cod_tipo_membresia`, `num_cuenta_dolares`, `num_cuenta_colones`, `num_cuenta_euros`, `num_cta_colones_ATA`, `num_cta_dolares_ATA`, `num_cc_colones_ATA`, `num_cc_dolares_ATA`, `num_iban_colones_ATA`, `num_iban_dolares_ATA`, `num_cedula_rep_legal`, `des_nombre_rep_legal`, `des_direccion_rep_legal`, `cod_estado_civil_rep_legal`, `des_profesion_rep_legal`, `des_nombre_contacto`, `des_telefono_contacto`, `des_correo_contacto`, `des_direccion_contacto`, `cod_actividad_economica`, `ind_tipo_cliente`, `ind_es_fideicomiso`, `ind_tipo_representante_legal`, `cod_pais`, `cod_provincia`, `cod_canton`, `cod_distrito`, `cod_tipo_sector`, `mon_riesgo_inherente`, `des_logo_cliente`, `des_descripcion`, `des_aux_tipo`, `des_aux_valor`, `fec_creacion`, `cod_usuario_modificacion`) VALUES
('3101727041', 2, 'Masterzon CR SA', 'Masterzon', 'CR', '2016-10-24', 1, '109260511', '', 8, '1020009297439539', '1020009297439462', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '109260511', 'Elio Rojas Rojas', 'San Jose, Curridabat, Canton Sanchez, de la casa de doña Lela 400SUR, 300OESTE, 100NORTE ', 2, 'ECONOMISTA, Costarricense, ', 'Jose Rivas Ramirez', '87408777', 'gguillen@masterzon.com', 'Ctro Comercial Sabana Sur, #31', 0, 'P', 'N', '', '1', 1, 1, 1, 2, '1.0000', 'images/logo_oficial_celeste.png', '', '', '', '2018-05-04 22:06:20', 'Francisco Ulate Azofeifa'),
('3101727694', 2, 'Granja AvÃ­cola Organica de Tilaran ', 'Granja AvÃ­cola Organica de Tilaran ', 'CR', '2018-03-10', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '303570865', 'Karol', 'N/R', 1, '0', 'N/R', 'Karol', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-03-10 19:40:31', 'WEB'),
('3101736419', 2, 'CIARRE BROKERAGE AND AVISORY SOCIEDAD ANONIMA', 'CIARRE BROKERAGE AND AVISORY S.A.', 'CR', '2017-07-31', 1, '1', '0', 9, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '1830937', 'vICENTE', 'N/R', 1, '0', 'N/R', 'vICENTE', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2017-07-31 11:59:59', 'WEB'),
('3102003210', 2, 'LUTZ HERMANOS & COMPAÑIA LTDA.', 'YAMAHA CR', 'CR', '2014-01-05', 1, '801070063', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 2, '', 'Diane Monge', '22115923', 'gguillen@masterzon.com', 'Uruca centro', 0, 'P', '', '', '', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2017-04-28 15:16:45', 'Jose Rivas'),
('3102347058', 2, 'JONES LANG LASALLE, LTDA', 'JLL (MERCK)', 'CR', '1816-11-01', 1, '801070063', '', 2, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'P', '', '', '', 0, 0, 0, 1, '0.0000', 'images/jll.png', 'Una historia de dos ciudades y expansión global\nLa historia de JLL abarca más de 200 años, pero sólo haremos referencia a los momentos más destacados:....... <a href=\'http://www.latinamerica.jll.com/latin-america/es-ar/acerca-de-nosotros/historia-global\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', NULL, NULL, '2017-05-24 14:22:44', 'Jose Rivas'),
('3102372096', 2, 'PROMEDICAL DE COSTA RICA', 'PROMEDICAL', 'CR', '2004-04-30', 2, '801070063', '', 9, '', '15101210010097023', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1-1117-0611', 'Leonel Arturo González Higaldo', 'Heredia, Belén, La Asunción', 2, 'Comerciante, Costarricense, ', 'Marilyn Morales', '22391026', 'gguillen@masterzon.com', 'Heredia, Belén, La Asunción, Frente al Salón del Reino de los Testigos de Jehová', 0, 'P', '', 'A', 'CR', 4, 7, 3, 2, '1.0000', 'images/ico.png', 'VENTA DE SUMINISTROS DE LIMPIEZA. <a href=\'https://www.facebook.com/pages/PROMEDICAL-de-Costa-Rica/141281502568818\' alt=\'+info\' height=\"25\" width=\"25\"/><img src=\'images/ICO.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-07-12 18:19:10', 'Rafael Villalobos'),
('3102457983', 2, 'Taller Industrial Rojas y Herrera Ltda', 'Taller Industrial Rojas y Herrera Ltda', 'CR', '2018-07-09', 1, '1', '0', 0, '0', '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '155812716817', 'Juan Carlos ', 'N/R', 1, '0', 'N/R', 'Juan Carlos ', 'gguillen@masterzon.com', 'N/R', 1, 'P', 'N', '', 'CR', 1, 1, 1, 1, '0.0000', '', NULL, NULL, NULL, '2018-07-09 14:26:23', 'WEB'),
('3102534789', 2, 'LATIN AMERICAN CAPITAL LTDA', 'LAC', 'CR', '2007-04-01', 1, '2147483647', '', 11, 'CR21010402240510714626', 'CR23010402240510713911', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '109910421', 'Mary Liz Ramirez Cedeño', 'San José, Central, Uruca', 2, 'Directora de Proyectos, Costarricense, ', 'Roberto Castillo', '88331367', 'gguillen@masterzon.com', 'San José, Central, Uruca, Del Hotel San José Palacio 400 al norte y 50 este', 0, 'P', 'N', 'A', '1', 1, 7, 1, 1, '1.0000', 'images/lac_ico.jpg', 'Latin American Capital S.R.L. conforma un conglomerado empresarial de carácter regional y multidisciplinario, que brinda servicios integrales para soluciones legales y financieras, seguras, ágiles, eficientes y confiables, utilizando una plataforma de inteligencia operativa legal y financiera innovadora, garantizando la eficacia y seguridad del tráfico de los recursos... <a href=\'http://lac.co.cr/\' alt=\'+info\' height=\"25\" width=\"25\"/><img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-01-18 16:37:18', 'Elio Rojas Rojas'),
('3102635849', 2, 'MATERIALES INDUSTRIALES INDUMA SRL', 'INDUMA', 'CR', '2000-01-01', 1, '206440727', '', 2, '10200009125809748', '10200009125809665', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1-1161-0555', 'Diego Alonso Flores Porras', 'San José, Santa Ana, Santa Ana, 150 oeste de la Cruz Roja', 1, 'Estudiante, Costarricense, ', 'Diego Alonso Flores Porras', '71413922', 'gguillen@masterzon.com', 'San José, Santa Ana, Santa Ana, 150 oeste de la Cruz Roja', 0, 'P', '', 'A', 'CR', 1, 1, 9, 1, '0.0000', 'images/induma.png', 'Materiales Industriales Induma S.R.L.200mts Oeste de la Cruz Roja,diagonal al Colegio de Santa Ana,San José, Costa Rica <a href=\'https://sites.google.com/a/indumacr.com/www/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a> ', '', '', '2017-11-06 17:18:40', 'Gerson'),
('3102698462', 2, 'TECNOLOGIAS MEDICAS Y SISTEMAS, TECMEDISI', 'TECMEDISI', 'CR', '2016-11-01', 1, '1', '', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'gguillen@masterzon.com', NULL, NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, '2016-11-25 13:45:18', 'gerson78'),
('3102734076', 2, 'ECHANDI, VARGAS Y ASOCIADOS SRL', 'ECHANDI, VARGAS', 'CR', '2017-04-19', 1, '2147483647', '', 2, '', '15108710010019677', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '83024226', 'gguillen@masterzon.com', '', 0, 'P', '', '', '188', 1, 1, 1, 1, '1.0000', NULL, NULL, NULL, NULL, '2017-04-19 18:48:32', 'Gerson'),
('3110672283', 2, 'FIDEICOMISO BANCO NACIONAL-MINISTERIO DE EDUCACION PUBLICA  LEY No 9124', 'FIDEICOMISO BNCR-MEP ', NULL, '2013-02-08', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/3110672283.png', 'Un fideicomiso suscrito entre el Ministerio de Educación Pública (MEP), Banco Interamericano de Desarrollo (BID) y Banco Nacional de Costa Rica (BNCR) con la intención de dotar de infraestructura educativa a 103 centros educativos entre el 2016 y 2018. Cuenta con un presupuesto de 167,5 millones de dólares. El fideicomiso fue producto de la Ley 9124, promulgada en el año 2013 y permitirá construir 79 escuelas y colegios, así como 29 canchas techadas.', '', '', '2018-02-06 17:29:00', 'Francisco Ulate Azofeifa'),
('4000000019', 2, 'BANCO DE COSTA RICA', 'BCR', 'CR', '1877-04-20', 1, '801070063', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', 'N', '', '188', 1, 1, 1, 1, '1.0000', 'images/logo-bcr.png', 'Nació con el propósito de ser una nueva opción bancaria entre las ya existentes y tuvo como funciones iniciales el prestar dinero, llevar cuentas corrientes, recibir depósitos y efectuar cobranzas, entre otras ... <a href=\'https://www.bancobcr.com/acerca%20del%20bcr/Historia.html\' alt=\'+info\' height=\"25\" width=\"25\"/><img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-02-15 21:22:15', 'Rafael Villalobos'),
('4000001128', 2, 'BANCO CREDITO AGRICOLA DE CARTAGO', 'BANCREDITO', 'CR', '1918-07-01', 0, '801070063', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '1', 1, 1, 1, 1, '1.0000', 'images/logoBancredito.PNG', 'BancrEdito, en sus orÃ­genes fue una casa bancaria de carÃ¡cter regional, fundada para promover el desarrollo de la Provincia de Cartago, mediante el impulso de la agricultura, tradicionalmente la actividad econÃ³mica por excelencia en las fÃ©rtiles tierras cartaginesas......... <a href=\'https://www.bancreditocr.com/conozcanos/quienes_somos/\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', NULL, NULL, '2017-04-19 17:22:36', 'Gerson'),
('4000001902', 2, 'INSTITUTO NACIONAL DE SEGUROS', 'INS', NULL, '1924-01-17', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/4000001902.gif', 'El Instituto Nacional de Seguros (INS) es una institución estatal de Costa Rica, la cual ofrece seguros y servicios relacionados a nivel nacional e internacional, además de promover la prevención de riesgos para el trabajo, el hogar y el tránsito de vehículos.', '', '', '2018-01-17 17:51:53', 'Francisco Ulate Azofeifa'),
('4000004017', 2, 'BANCO CENTRAL DE COSTA RICA', 'BCCR', NULL, '1950-01-28', NULL, '206440727', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/ico_bccr.jpeg', 'En 1948, al decretarse la nacionalización de la banca privada -recepción de depósitos del público - y dada la necesidad de dotar al nuevo Sistema Bancario Nacional de una integración orgánica adecuada y una orientación eficiente por parte del Estado, se hizo más urgente la necesidad de establecer el Banco Central como órgano independiente y rector de la política económica, monetaria y crediticia del país. Con este propósito se promulgó la Ley 1130. <a href=\'https://www.bccr.fi.cr/seccion-sobre-bccr/rese%C3%B1a-hist%C3%B3rica\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2017-09-07 21:34:12', 'Francisco Ulate Azofeifa'),
('4000042138', 1, 'INSTITUTO COSTARRICENSE DE ACUEDUCTOS Y ALCANTARILLADOS', ' A Y A', 'CR', '2017-05-07', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'N', '', '', '', 0, 0, 0, 0, '0.0000', NULL, '', '', '', '2018-05-30 22:32:56', 'Francisco Ulate Azofeifa'),
('4000042139', 2, 'INSTITUTO COSTARRICENSE DE ELECTRICIDAD', 'ICE', 'CR', '1949-05-08', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '', 0, 0, 0, 1, '0.0000', 'images/ICE.png', 'El Instituto Costarricense de Electricidad (ICE) fue creado por el Decreto - Ley No.449 del 8 de abril de 1949........ <a href=\'https://www.grupoice.com/wps/portal/ICE/AcercadelGrupoICE/quienes-somos/historia-del-ice\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:33:21', 'Francisco Ulate Azofeifa'),
('4000042143', 2, 'INSTITUTO DE DESARROLLO RURAL', 'INDER', NULL, '1962-10-25', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 'El Inder tiene por origen al Instituto de Tierras y Colonización (ITCO), creado mediante Ley No. 2825 del 14 octubre de 1961, denominado por su naturaleza Ley de Tierras y Colonización, nace a la vida jurídica-administrativa mediante celebración de la primera sesión de Junta Directiva, el 25 de octubre de 1962.  Posteriormente, a través de la Ley No. 6735 del 29 marzo de 1982, se transforma el Instituto de Tierras y Colonización, en Instituto de Desarrollo Agrario (IDA), con las mismas prerrogativas constitutivas de la ley anterior (Artículo 1). Otra ley muy relacionada con la actividad ordinaria del Instituto es la Ley de Jurisdicción Agraria. Nº. 6734 del 25 de marzo de 1982. El 22 de marzo del 2012 la Asamblea Legislativa aprueba la Ley 9036, que transforma al Instituto de Desarrollo Agrario en el Instituto de Desarrollo Rural.', '', '', '2018-05-30 22:33:50', 'Francisco Ulate Azofeifa'),
('4000042145', 2, 'INSTITUTO TECNOLOGICO DE COSTA RICA', 'I.T.C.R', 'CR', '1971-06-10', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '', 0, 0, 0, 1, '0.0000', 'images/TEC.png', 'El TecnoLOgico de Costa Rica (TEC) es una instituciÃ³n nacional autÃ³noma de educaciÃ³n superior universitaria, dedicada a la docencia, la investigaciÃ³n y la extensiÃ³n de la tecnologÃ­a y las ciencias conexas para el desarrollo de Costa Rica. Fue creado mediante ley No. 4.777 del 10 de junio de 1971........ <a href=\'https://www.tec.ac.cr/que-es-tec\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:34:11', 'Francisco Ulate Azofeifa'),
('4000042147', 2, 'CAJA COSTARRICENSE DE SEGURO SOCIAL', 'CCSS', 'CRC', '1941-11-01', 0, '2147483647', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 6, 'X', '', 'G', '188', 1, 101, 10101, 1, '0.0000', 'images/logoCCSS.png', '1940; La Caja Costarricense de Seguro Social (CCSS) se crea como una Institución semiautónoma el 1 de noviembre de 1941 mediante Ley No. 17 durante la administración del Dr. Rafael Angel Calderón Guardia.........<a href=\'http://www.ccss.sa.cr/cultura#memorias\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-01-05 16:31:09', 'Rafael Villalobos'),
('4000042149', 2, 'UNIVERSIDAD DE COSTA RICA', 'UCR', NULL, '1940-09-26', NULL, '801070063', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, '0.0000', 'images/4000042149.png', 'La Universidad de Costa Rica es una institución de educación superior y cultura, autónoma constitucionalmente y democrática, constituida por una comunidad de profesores y profesoras, estudiantes y personal administrativo, dedicada a la enseñanza, la investigación, la acción social, el estudio, la meditación, la creación artística y la difusión del conocimiento.', '', '', '2018-01-05 16:59:11', 'Rafael Villalobos'),
('4000042150', 2, 'UNIVERSIDAD NACIONAL', 'UNA', NULL, '1973-02-15', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/4000042150.png', 'La Universidad Nacional de Costa Rica (UNA) es una universidad publica costarricense con gran prestigio a nivel nacional e internacional ademas de ser reconocida como una universidad dedicada a la investigacion y posicionada entre las mejores universidades a nivel mundial. Es una de las mejores universidades de la Republica de Costa Rica y America Latina. Segun el mas reciente estudio con base en los estandares internacionales utilizados para evaluar a las universidades, la Universidad Nacional de Costa Rica ocupa el lugar numero 55 en America Latina y el 701 a nivel mundial.', '', '', '2018-05-21 18:34:32', 'Francisco Ulate Azofeifa'),
('4000042151', 2, 'UNIVERSIDAD ESTATAL A DISTANCIA', 'UNED', NULL, '1977-01-03', NULL, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', NULL, 'X', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'images/4000042151.png', 'La Universidad Estatal a Distancia (UNED), es una de las cinco universidades públicas de Costa Rica. Se encuentra ubicada en Sabanilla, Montes de Oca, de modalidad a distancia, es la segunda universidad en cantidad de estudiantes; y es la de mayor cobertura en el país. Posee además su propia editorial que produce una gran variedad tanto de libros de texto que cubren la mayor parte de las necesidades de la universidad, como de obras ensayísticas, de investigación, etc. Esta institución fue creada en 1977.', '', '', '2018-01-24 18:37:40', 'Francisco Ulate Azofeifa'),
('4000042152', 2, 'BANCO POPULAR Y DE DESARROLLO COMUNAL', 'BANCO POPULAR', 'CR', '1969-07-11', 1, '2147483647', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '', 0, 0, 0, 1, '0.0000', 'images/banco-popular.png', '1901: El Banco Popular surge de la iniciativa de transformar un fondo de ahorro capitalizado, llamado El Monte de la Piedad, dedicado a pignorar alhajas y prendas para solventar las necesidades urgentes de los trabajadores…<a href=\'https://www.bancopopular.fi.cr/BPOP/Nosotros/Historia.aspx\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-01-05 16:30:15', 'Rafael Villalobos'),
('4000045127', 2, 'INSTITUTO NACIONAL DE APRENDIZAJE', 'I.N.A.', 'CR', '1965-05-21', 1, '2147483647', '', 0, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '', 0, 0, 0, 1, '0.0000', 'images/ina.png', 'El Instituto Nacional de Aprendizaje (INA) es una entidad autónoma creada por la ley No.3506 del 21 de mayo de 1965, reformada por su Ley Orgánica No. 6868 del 6 de mayo de 1983.  Su principal tarea es promover y desarrollar la capacitación y formación profesional de los hombres y mujeres en todos los sectores de la producción para....... <a href=\'http://www.ina.ac.cr/faq/\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', '', '', '2018-05-30 22:34:37', 'Francisco Ulate Azofeifa'),
('4000100021', 2, 'BANCO NACIONAL DE COSTA RICA', 'B.N.C.R.', 'cr', '1914-10-09', 1, '2147483647', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'X', '', '', '1', 1, 1, 1, 1, '1.0000', 'images/logoBNCR.png', 'El Banco Nacional nació en 1914, al iniciarse la Administración del presidente Alfredo González Flores. En aquel momento comenzaba también la I Guerra Mundial. Previendo una posible contracción de las exportaciones, el Gobierno requería estimular la demanda interna..... <a href=\'https://www.bncr.fi.cr/BNCR/Conozcanos/Historia.aspx\' alt=\'+info\' height=\"25\" width=\"25\"/></a>', NULL, NULL, '2017-06-27 21:34:50', 'Gerson'),
('602240460', 1, 'William Chen Mok', 'William Chen Mok', 'CR', '2017-06-04', 1, '801070063', '', 2, '10200007196460020', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '602240460', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'N', '', '', '', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2017-08-18 15:27:07', 'Gerson'),
('800820648', 1, 'Christopher Norman', 'Cris Norman', 'EEUU', '2017-07-05', 0, '801070063', '', 6, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 1, '', '', '', 'gguillen@masterzon.com', '', 0, 'N', '', '', '', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2017-07-05 18:48:40', 'Gerson'),
('801070063', 1, 'Cesar Peralta', 'Cesar', 'cr', '2017-02-16', 1, '801070063', '', 2, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '', '', 4, '', 'Cesar Peralta', '71032778', 'gguillen@masterzon.com', '', 0, 'N', '', '', '', 0, 0, 0, 0, '0.0000', NULL, NULL, NULL, NULL, '2017-02-16 20:21:15', 'Gerson');

-- --------------------------------------------------------

--
-- Table structure for table `sis_catalogo_membresias`
--

CREATE TABLE `sis_catalogo_membresias` (
  `cod_tipo_membresia` int(5) NOT NULL,
  `des_tipo_membresia` varchar(50) NOT NULL,
  `num_fee_transaccional` decimal(10,2) NOT NULL,
  `mon_comision_contratos` decimal(10,2) NOT NULL DEFAULT '1.00',
  `num_meses_vigencia` int(5) DEFAULT NULL,
  `num_cantidad_puntos` int(5) DEFAULT NULL,
  `mon_comision_minima_colones` decimal(20,2) DEFAULT '0.00',
  `mon_comision_minima_dolares` decimal(20,2) NOT NULL DEFAULT '0.00',
  `mon_comision_forex` decimal(10,2) NOT NULL DEFAULT '0.00',
  `mon_comision_lending` decimal(10,2) NOT NULL,
  `fec_creacion_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usr_creacion_modificacion` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla que almacena los tipos de membresias y sus condiciones';

--
-- Dumping data for table `sis_catalogo_membresias`
--

INSERT INTO `sis_catalogo_membresias` (`cod_tipo_membresia`, `des_tipo_membresia`, `num_fee_transaccional`, `mon_comision_contratos`, `num_meses_vigencia`, `num_cantidad_puntos`, `mon_comision_minima_colones`, `mon_comision_minima_dolares`, `mon_comision_forex`, `mon_comision_lending`, `fec_creacion_modificacion`, `usr_creacion_modificacion`) VALUES
(0, 'NoReg', '0.00', '0.00', 0, 0, '0.00', '0.00', '0.00', '0.00', '2017-11-09 18:16:45', 'gerson'),
(1, 'Silver (Libre)', '2.00', '3.00', 12, 0, '85000.00', '150.00', '0.00', '2.00', '2016-11-22 16:58:13', 'dba'),
(2, 'MasterGold', '2.00', '2.00', 12, 0, '25000.00', '50.00', '0.00', '2.00', '2016-11-22 16:58:13', 'dba'),
(4, 'MasterBlack', '1.50', '1.50', 12, 0, '25000.00', '50.00', '0.00', '2.00', '2016-11-22 17:02:12', 'dba'),
(5, 'MasterCoope', '2.00', '2.00', 12, 0, '25000.00', '50.00', '0.00', '2.00', '2017-05-25 20:26:53', 'dba'),
(6, 'Masterzon', '2.40', '3.40', 12, 0, '25000.00', '50.00', '0.00', '6.25', '2017-05-25 20:31:10', 'dba'),
(7, 'MasterPyme', '1.50', '2.50', 12, 0, '40000.00', '45.00', '0.00', '2.00', '2017-05-25 20:31:10', 'dba'),
(8, 'MasterFondo', '0.00', '0.00', 12, 0, '0.00', '0.00', '0.00', '2.00', '2017-06-19 17:11:52', 'dba'),
(9, 'MasterPlatino', '3.00', '3.50', 12, 0, '25000.00', '50.00', '0.00', '0.00', '2017-07-31 20:10:16', 'dba'),
(10, 'PNG', '0.00', '0.00', 12, 0, '0.00', '0.00', '0.00', '0.00', '2017-10-10 18:28:44', 'gerson'),
(11, 'MasterGreen', '2.00', '2.50', 12, 0, '25000.00', '50.00', '0.00', '2.50', '2018-01-18 16:32:37', 'gerson'),
(12, 'Master Club', '3.50', '4.00', 12, NULL, '25000.00', '50.00', '0.00', '0.00', '2018-02-01 16:18:16', '');

-- --------------------------------------------------------

--
-- Table structure for table `sis_datos_tmp_contratos`
--

CREATE TABLE `sis_datos_tmp_contratos` (
  `num_identificacion` varchar(50) NOT NULL,
  `num_operacion` varchar(50) NOT NULL,
  `cod_seccion` int(5) NOT NULL,
  `cod_variable` varchar(50) NOT NULL,
  `des_valor_variable` varchar(1000) DEFAULT NULL,
  `fec_registro` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Almacena los datos del cliente y la operacion de cesion factoring de forma temporal';

-- --------------------------------------------------------

--
-- Table structure for table `sis_datos_tmp_factura_estandar`
--

CREATE TABLE `sis_datos_tmp_factura_estandar` (
  `num_identificacion` varchar(50) NOT NULL,
  `num_operacion` varchar(50) NOT NULL,
  `can_fracciones` int(1) NOT NULL DEFAULT '1',
  `cod_seccion` int(5) NOT NULL,
  `cod_variable` varchar(50) NOT NULL,
  `des_valor_variable` varchar(1000) DEFAULT NULL,
  `fec_registro` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla que almacena datos temporales para la creacion de las facturas estandar';

-- --------------------------------------------------------

--
-- Table structure for table `sis_datos_tmp_letras_cambio`
--

CREATE TABLE `sis_datos_tmp_letras_cambio` (
  `num_identificacion` varchar(50) NOT NULL,
  `num_operacion` varchar(50) NOT NULL,
  `cod_seccion` int(5) NOT NULL,
  `cod_variable` varchar(50) NOT NULL,
  `des_valor_variable` varchar(1000) DEFAULT NULL,
  `fec_registro` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla que almacena datos temporales para la creacion de las letras de cambio';

-- --------------------------------------------------------

--
-- Table structure for table `sis_ejecutivos`
--

CREATE TABLE `sis_ejecutivos` (
  `num_cedula` varchar(50) NOT NULL,
  `nom_ejecutivo` varchar(150) NOT NULL,
  `des_nick_name` varchar(20) NOT NULL,
  `cod_estado` char(1) NOT NULL DEFAULT 'I',
  `des_email_1` varchar(150) NOT NULL,
  `des_email_2` varchar(150) DEFAULT NULL,
  `des_telefono` varchar(50) DEFAULT NULL,
  `fec_modificacion` date NOT NULL,
  `cod_usuario_modificacion` varchar(50) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='Tabla que almacena los ejecutivos del sistema';

--
-- Dumping data for table `sis_ejecutivos`
--

INSERT INTO `sis_ejecutivos` (`num_cedula`, `nom_ejecutivo`, `des_nick_name`, `cod_estado`, `des_email_1`, `des_email_2`, `des_telefono`, `fec_modificacion`, `cod_usuario_modificacion`) VALUES
('3101727041', 'MASTERZON CR', '', 'A', 'info@masterzon.com', 'jrivas@masterzon.com', '22327794', '2018-05-31', 'Grettel'),
('109260511', 'Helio Francisco Rojas Rojas', '', 'A', 'erojas7@gmail.com', '', '83175053', '2018-05-04', 'Francisco Ulate Azofeifa');

-- --------------------------------------------------------

--
-- Table structure for table `sis_emisiones`
--

CREATE TABLE `sis_emisiones` (
  `cod_emision` int(11) NOT NULL,
  `cod_instrumento` varchar(20) COLLATE utf16_unicode_ci DEFAULT NULL,
  `fec_vencimiento` date DEFAULT NULL,
  `ced_cooperativa` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  `mon_facial` decimal(20,2) DEFAULT NULL,
  `mon_minimo_negociacion` decimal(20,2) DEFAULT NULL,
  `ind_estado` char(1) COLLATE utf16_unicode_ci DEFAULT NULL COMMENT 'R=Registrada, P=Publicada, B=Bloqueada',
  `num_periodicidad` int(3) NOT NULL,
  `obs_emision` varchar(250) COLLATE utf16_unicode_ci NOT NULL,
  `des_ruta_prospecto` varchar(250) COLLATE utf16_unicode_ci NOT NULL,
  `fec_modificacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `usr_modificacion` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci COMMENT='Tabla que almacena todas las emisiones del sistema, y controla los estados de estas con respecto a la pizarra de negociacion-';

-- --------------------------------------------------------

--
-- Table structure for table `sis_emisiones_privadas`
--

CREATE TABLE `sis_emisiones_privadas` (
  `cod_emision` int(11) NOT NULL,
  `cod_instrumento` varchar(20) COLLATE utf16_unicode_ci DEFAULT NULL,
  `fec_vencimiento` date DEFAULT NULL,
  `ced_cooperativa` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  `mon_facial` decimal(20,2) DEFAULT NULL,
  `mon_minimo_negociacion` decimal(20,2) DEFAULT NULL,
  `ind_estado` char(1) COLLATE utf16_unicode_ci DEFAULT NULL COMMENT 'R=Registrada, P=Publicada, B=Bloqueada',
  `num_periodicidad` int(3) DEFAULT NULL,
  `obs_emision` varchar(250) COLLATE utf16_unicode_ci DEFAULT NULL,
  `des_ruta_prospecto` varchar(250) COLLATE utf16_unicode_ci DEFAULT NULL,
  `fec_modificacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `usr_modificacion` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci COMMENT='Tabla que almacena todas las emisiones privadas de PYMES del sistema, y controla los estados de estas con respecto a la pizarra de negociacion-';

--
-- Dumping data for table `sis_emisiones_privadas`
--

INSERT INTO `sis_emisiones_privadas` (`cod_emision`, `cod_instrumento`, `fec_vencimiento`, `ced_cooperativa`, `mon_facial`, `mon_minimo_negociacion`, `ind_estado`, `num_periodicidad`, `obs_emision`, `des_ruta_prospecto`, `fec_modificacion`, `usr_modificacion`) VALUES
(1, 'p_US$', '2019-11-09', '3101677940', '140000.00', '140000.00', 'R', 1, 'TITULO BROKERS', 'prospectos_adjuntos/p_US$_3101677940_3735.pdf', '2018-11-07 17:33:51', 'jrivas');

-- --------------------------------------------------------

--
-- Table structure for table `sis_estados_operaciones`
--

CREATE TABLE `sis_estados_operaciones` (
  `cod_estado` int(5) NOT NULL,
  `des_estado` varchar(50) NOT NULL,
  `fec_modificacion` date NOT NULL,
  `usr_modificacion` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla que registra los tipos de estados de las operaciones';

--
-- Dumping data for table `sis_estados_operaciones`
--

INSERT INTO `sis_estados_operaciones` (`cod_estado`, `des_estado`, `fec_modificacion`, `usr_modificacion`) VALUES
(1, 'Registrada', '2016-05-03', 'gerson78'),
(2, 'Cambio Rendimiento', '2016-05-03', 'gerson78'),
(3, 'Cambio Porcentaje', '2016-05-03', 'gerson78'),
(4, 'Publicada', '2016-05-03', 'gerson78'),
(5, 'Calzada', '2016-05-03', 'gerson78'),
(6, 'Liquidada', '2016-05-03', 'gerson78'),
(7, 'Bloqueada', '2016-06-23', 'gerson78'),
(8, 'Vencida', '2017-07-11', ''),
(9, 'Confirmada', '0000-00-00', ''),
(10, 'Descartada', '2016-11-30', 'dba'),
(11, 'Pagada', '2016-12-19', 'dba'),
(12, 'Fracción Calzada', '0000-00-00', '');

-- --------------------------------------------------------

--
-- Table structure for table `sis_estado_civil`
--

CREATE TABLE `sis_estado_civil` (
  `cod_estado_civil` int(5) NOT NULL,
  `des_estado_civil` varchar(100) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sis_estado_civil`
--

INSERT INTO `sis_estado_civil` (`cod_estado_civil`, `des_estado_civil`) VALUES
(1, 'Soltero'),
(2, 'Casado'),
(3, 'Viudo'),
(4, 'Divorciado'),
(5, 'Unión libre');

-- --------------------------------------------------------

--
-- Table structure for table `sis_feriados`
--

CREATE TABLE `sis_feriados` (
  `cod_feriado` int(5) NOT NULL,
  `des_feriado` varchar(50) NOT NULL,
  `fec_feriado` date NOT NULL,
  `fec_modificacion` date NOT NULL,
  `usr_modificacion` varchar(50) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='Tabla para feriados de CR';

--
-- Dumping data for table `sis_feriados`
--

INSERT INTO `sis_feriados` (`cod_feriado`, `des_feriado`, `fec_feriado`, `fec_modificacion`, `usr_modificacion`) VALUES
(8, 'Día de la Madre', '2016-08-15', '2016-06-19', 'marlon'),
(1, 'Año Nuevo', '2016-01-01', '2016-06-21', 'marlon'),
(2, 'Jueves Santo', '2017-04-13', '2016-06-21', 'marlon'),
(3, 'Viernes Santo', '2017-04-14', '2016-06-21', 'marlon'),
(4, 'Día de Juan Santamaría', '2017-04-11', '2016-06-21', 'marlon'),
(5, 'Día del Trabajo', '2017-05-01', '2016-06-21', 'marlon'),
(6, 'Anexión del Partido de Nicoya a Costa Rica', '2016-07-25', '2016-06-21', 'marlon'),
(7, 'Día de la Virgen de los Ángeles', '2016-08-02', '2016-06-19', 'marlon'),
(9, 'Día de la Independencia', '2016-09-15', '2016-06-19', 'marlon'),
(10, 'Día de las Culturas', '2016-10-12', '2016-06-19', 'marlon'),
(11, 'Navidad', '2016-12-25', '2016-06-19', 'marlon'),
(19, 'Día de la Madre17', '2017-08-15', '2016-06-22', 'marlon'),
(18, 'Día de la Virgen de los Ángeles17', '2017-08-02', '2016-06-22', 'marlon'),
(17, 'Anexión del Partido de Nicoya a Costa Rica17', '2017-07-25', '2016-06-22', 'marlon'),
(15, 'Día de Juan Santamaría17', '2017-04-11', '2016-06-22', 'marlon'),
(14, 'Viernes Santo17', '2017-04-14', '2016-06-22', 'marlon'),
(13, 'Jueves Santo17', '2017-04-13', '2016-06-22', 'marlon'),
(12, 'Año Nuevo17', '2017-01-01', '2016-06-22', 'marlon'),
(20, 'Día de la Independencia17', '2017-09-15', '2016-06-22', 'marlon'),
(44, 'Navidad2017', '2017-12-25', '0000-00-00', ''),
(36, 'Cierre fideicomiso', '2016-12-26', '0000-00-00', ''),
(37, 'Cierre fideicomiso', '2016-12-27', '0000-00-00', ''),
(38, 'Cierre fideicomiso', '2016-12-28', '0000-00-00', ''),
(39, 'Cierre fideicomiso', '2016-12-29', '0000-00-00', ''),
(40, 'Cierre fideicomiso', '2016-12-30', '0000-00-00', ''),
(41, 'semana santa 1', '2017-04-10', '0000-00-00', ''),
(42, 'semana santa 2', '2017-04-12', '0000-00-00', ''),
(43, 'Día de las Culturas 2017', '2017-10-16', '0000-00-00', ''),
(45, 'Año Nuevo2018', '2018-01-01', '0000-00-00', ''),
(46, 'Jueves Santo 2018', '2018-03-29', '0000-00-00', ''),
(47, 'Viernes Santo 2018', '2018-03-30', '0000-00-00', ''),
(57, 'Dia de Juan Santamaria', '2018-04-11', '0000-00-00', ''),
(49, 'Día del Trabajo 2018', '2018-05-01', '0000-00-00', ''),
(50, 'Día de la Anexión de Guanacaste 2018', '2018-07-25', '0000-00-00', ''),
(51, 'Día de la Virgen de Los Ángeles 2018', '2018-08-02', '0000-00-00', ''),
(52, 'Día de la Madre 2018', '2018-08-15', '0000-00-00', ''),
(56, 'Miércoles Santo', '2018-03-28', '0000-00-00', ''),
(55, 'Cierre Fideicomiso', '2017-12-15', '0000-00-00', '');

-- --------------------------------------------------------

--
-- Table structure for table `sis_fuentes_tc_monedas`
--

CREATE TABLE `sis_fuentes_tc_monedas` (
  `cod_fuente_tc` int(5) NOT NULL,
  `des_fuente_tc` varchar(50) NOT NULL,
  `des_nick_name` varchar(20) NOT NULL,
  `cod_entidad` int(3) NOT NULL,
  `fec_modificacion` datetime NOT NULL,
  `usr_registro` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla que almacena las fuentes de referencia para tipos de cambio.';

--
-- Dumping data for table `sis_fuentes_tc_monedas`
--

INSERT INTO `sis_fuentes_tc_monedas` (`cod_fuente_tc`, `des_fuente_tc`, `des_nick_name`, `cod_entidad`, `fec_modificacion`, `usr_registro`) VALUES
(0, 'N/A', 'N/A', 0, '2017-05-25 00:00:00', 'dba'),
(1, 'BAC San José S.A.', 'BAC', 102, '2017-03-14 00:00:00', 'dba'),
(2, 'Banco de Costa Rica', 'BCR', 152, '2017-03-14 00:00:00', 'dba'),
(3, 'Banco Hipotecario de la Vivienda', 'Davivienda', 162, '2017-03-14 00:00:00', 'dba'),
(4, 'Masterzon CR SA', 'Mz', 99, '2017-03-14 00:00:00', 'dba'),
(5, 'Banco Popular y de Desarrollo Comunal ', 'BPDC', 161, '2017-03-14 00:00:00', 'dba'),
(6, 'Banco BCT, S. A.', 'BCT', 107, '1899-11-30 00:00:00', 'DBA'),
(7, 'Banco Central de Costa Rica', 'BCCR', 100, '2017-04-04 00:00:00', 'DBA'),
(8, 'COOPERATIVA DE AHORRO Y CRÉDITO - COOCIQUE R.L', 'COOCIQUE', 811, '2017-11-02 22:26:06', 'Gerson'),
(9, 'Banco Nacional Costa Rica', 'BNCR', 151, '2017-11-02 22:12:45', 'Gerson');

-- --------------------------------------------------------

--
-- Table structure for table `sis_notificaciones_sms`
--

CREATE TABLE `sis_notificaciones_sms` (
  `cod_notificacion` int(10) NOT NULL,
  `num_remitente` varchar(45) DEFAULT NULL,
  `num_destinatario` varchar(45) DEFAULT NULL,
  `ced_destinatario` varchar(45) DEFAULT NULL,
  `des_mensaje` varchar(140) DEFAULT NULL,
  `cod_estado` char(1) DEFAULT NULL,
  `ind_prioridad` int(1) DEFAULT NULL,
  `des_evento_disparador` varchar(45) DEFAULT NULL,
  `fec_hora_envio` datetime DEFAULT NULL,
  `fec_hora_registro` datetime DEFAULT CURRENT_TIMESTAMP,
  `usr_registro` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla que almacena los mensajes por el canal SMS. Notificaciones enviadas por eventos de calce, puja o nuevos negocios en Masterzon';

--
-- Dumping data for table `sis_notificaciones_sms`
--

INSERT INTO `sis_notificaciones_sms` (`cod_notificacion`, `num_remitente`, `num_destinatario`, `ced_destinatario`, `des_mensaje`, `cod_estado`, `ind_prioridad`, `des_evento_disparador`, `fec_hora_envio`, `fec_hora_registro`, `usr_registro`) VALUES
(1, '+50687627837', '87408777', '3101727041', 'ELIO calza operacion #1 al 11.0% anual.', 'P', 2, 'calce', NULL, '2018-11-07 17:45:09', 'erojas '),
(2, '+50687627837', '87408777', '3101727041', 'Cora_Bartels calza operacion #1 al 10.0% anual.', 'P', 2, 'calce', NULL, '2018-11-08 10:57:15', 'cbartels');

-- --------------------------------------------------------

--
-- Table structure for table `sis_obs_operaciones_factoring`
--

CREATE TABLE `sis_obs_operaciones_factoring` (
  `num_operacion` int(10) NOT NULL,
  `obs_operacion` varchar(500) NOT NULL,
  `usr_modificacion` varchar(50) NOT NULL,
  `fec_modificacion` date NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `sis_operaciones_cooperativas`
--

CREATE TABLE `sis_operaciones_cooperativas` (
  `num_operacion` int(11) NOT NULL,
  `cod_emision` int(11) NOT NULL,
  `cod_tipo_factura` int(5) NOT NULL,
  `cod_vendedor` varchar(50) CHARACTER SET latin1 NOT NULL,
  `ind_tipo_cliente` char(1) NOT NULL COMMENT 'C = Cooperativa / P = Pyme (emisiones privadas)  / X = No Indica',
  `cod_tipo_moneda` int(5) NOT NULL,
  `ind_operacion_liquidada` char(1) CHARACTER SET latin1 NOT NULL DEFAULT 'N',
  `cod_tipo_plazo` int(5) NOT NULL,
  `cod_estado` int(5) NOT NULL,
  `mon_facial` decimal(20,2) NOT NULL,
  `mon_transado` decimal(20,2) NOT NULL,
  `ind_fraccionado` char(1) CHARACTER SET latin1 NOT NULL DEFAULT 'N',
  `ind_calce_completo` char(1) CHARACTER SET latin1 NOT NULL DEFAULT 'S' COMMENT 'Este campo almacena un valor S cuando la operacion fraccionada debe calzar en T todas sus partes. Y almacena una N cuando las partes pueden calzar en diferentes dias.',
  `num_rendimiento` decimal(10,1) NOT NULL,
  `num_descuento` decimal(10,0) NOT NULL,
  `fec_emision` date NOT NULL,
  `fec_estimada_pago` date NOT NULL,
  `fec_liquidacion` date NOT NULL,
  `mon_liquidacion_comprador` decimal(20,2) NOT NULL COMMENT 'Monto neto a liquidar al comprador',
  `mon_comision_comprador` decimal(20,2) NOT NULL DEFAULT '0.00',
  `mon_liquidacion_vendedor` decimal(20,2) NOT NULL COMMENT 'Monto neto a liquidar al vendedor',
  `mon_comision_vendedor` decimal(20,2) NOT NULL DEFAULT '0.00',
  `mon_tipo_cambio_liquidacion` decimal(10,2) NOT NULL COMMENT 'Valor del tipo de cambio (fuente Mz) al momento de liquidar la operacion',
  `num_parametro_liquidacion` decimal(20,2) NOT NULL COMMENT 'Valor almacenado en el parametro SIS025 al momento de liquidar la operacion',
  `mon_costo_transferencia` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Monto del costo de la transferencia SINPE',
  `fec_vencimiento` date DEFAULT NULL COMMENT 'Fecha en que se aplicó el vencimiento, o la confirmacion de pago de la operacion desde el backofice',
  `ind_contrato_firmado` char(1) CHARACTER SET latin1 NOT NULL DEFAULT 'N',
  `ind_fondos_transferidos` char(1) CHARACTER SET latin1 NOT NULL DEFAULT 'N',
  `des_ruta_certificado` varchar(200) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `fec_registro` datetime NOT NULL,
  `usr_registro` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sis_operaciones_pymes`
--

CREATE TABLE `sis_operaciones_pymes` (
  `num_operacion` int(11) NOT NULL,
  `cod_emision` int(11) NOT NULL,
  `cod_tipo_factura` int(5) NOT NULL,
  `cod_vendedor` varchar(50) CHARACTER SET latin1 NOT NULL,
  `ind_tipo_cliente` char(1) NOT NULL COMMENT 'C = Cooperativa / P = Pyme (emisiones privadas)  / X = No Indica',
  `cod_tipo_moneda` int(5) NOT NULL,
  `ind_operacion_liquidada` char(1) CHARACTER SET latin1 NOT NULL DEFAULT 'N',
  `cod_tipo_plazo` int(5) NOT NULL,
  `cod_estado` int(5) NOT NULL,
  `mon_facial` decimal(20,2) NOT NULL,
  `mon_transado` decimal(20,2) NOT NULL,
  `ind_fraccionado` char(1) CHARACTER SET latin1 NOT NULL DEFAULT 'N',
  `ind_calce_completo` char(1) CHARACTER SET latin1 NOT NULL DEFAULT 'S' COMMENT 'Este campo almacena un valor S cuando la operacion fraccionada debe calzar en T todas sus partes. Y almacena una N cuando las partes pueden calzar en diferentes dias.',
  `num_rendimiento` decimal(10,1) NOT NULL,
  `num_descuento` decimal(10,0) NOT NULL,
  `fec_emision` date NOT NULL,
  `fec_estimada_pago` date NOT NULL,
  `fec_liquidacion` date NOT NULL,
  `mon_liquidacion_comprador` decimal(20,2) NOT NULL COMMENT 'Monto neto a liquidar al comprador',
  `mon_comision_comprador` decimal(20,2) NOT NULL DEFAULT '0.00',
  `mon_liquidacion_vendedor` decimal(20,2) NOT NULL COMMENT 'Monto neto a liquidar al vendedor',
  `mon_comision_vendedor` decimal(20,2) NOT NULL DEFAULT '0.00',
  `mon_tipo_cambio_liquidacion` decimal(10,2) NOT NULL COMMENT 'Valor del tipo de cambio (fuente Mz) al momento de liquidar la operacion',
  `num_parametro_liquidacion` decimal(20,2) NOT NULL COMMENT 'Valor almacenado en el parametro SIS025 al momento de liquidar la operacion',
  `mon_costo_transferencia` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Monto del costo de la transferencia SINPE',
  `fec_vencimiento` date DEFAULT NULL COMMENT 'Fecha en que se aplicó el vencimiento, o la confirmacion de pago de la operacion desde el backofice',
  `ind_contrato_firmado` char(1) CHARACTER SET latin1 NOT NULL DEFAULT 'N',
  `ind_fondos_transferidos` char(1) CHARACTER SET latin1 NOT NULL DEFAULT 'N',
  `des_ruta_certificado` varchar(200) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `fec_registro` datetime NOT NULL,
  `usr_registro` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `sis_operaciones_pymes`
--

INSERT INTO `sis_operaciones_pymes` (`num_operacion`, `cod_emision`, `cod_tipo_factura`, `cod_vendedor`, `ind_tipo_cliente`, `cod_tipo_moneda`, `ind_operacion_liquidada`, `cod_tipo_plazo`, `cod_estado`, `mon_facial`, `mon_transado`, `ind_fraccionado`, `ind_calce_completo`, `num_rendimiento`, `num_descuento`, `fec_emision`, `fec_estimada_pago`, `fec_liquidacion`, `mon_liquidacion_comprador`, `mon_comision_comprador`, `mon_liquidacion_vendedor`, `mon_comision_vendedor`, `mon_tipo_cambio_liquidacion`, `num_parametro_liquidacion`, `mon_costo_transferencia`, `fec_vencimiento`, `ind_contrato_firmado`, `ind_fondos_transferidos`, `des_ruta_certificado`, `fec_registro`, `usr_registro`) VALUES
(1, 1, 1, '3101677940', 'P', 2, 'N', 365, 5, '140000.00', '140000.00', 'N', 'S', '10.0', '100', '2018-11-07', '2019-11-09', '2018-11-08', '0.00', '0.00', '0.00', '0.00', '1.00', '0.00', '0.00', '2019-11-09', 'N', 'N', 'n/r', '2018-11-07 17:34:23', 'jrivas');

-- --------------------------------------------------------

--
-- Table structure for table `sis_parametros`
--

CREATE TABLE `sis_parametros` (
  `cod_parametro` varchar(6) NOT NULL,
  `des_parametro` varchar(300) NOT NULL,
  `val_parametro` varchar(1500) NOT NULL,
  `fec_modificacion` datetime NOT NULL,
  `usr_modificacion` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Taba que almacena los parametros del sistema.';

--
-- Dumping data for table `sis_parametros`
--

INSERT INTO `sis_parametros` (`cod_parametro`, `des_parametro`, `val_parametro`, `fec_modificacion`, `usr_modificacion`) VALUES
('CWF001', 'Monto meta de recaudacion del proyecto Tunel de la Ciencia Max Plank..', '250000', '2017-11-19 00:00:00', 'Grettel'),
('CWF002', 'Fecha finalizacion del proyecto Crowdfunding Adastra RocketFecha finalizacion del proyecto Crowdfunding PNG', '2018-04-13', '2016-12-21 00:00:00', 'dba'),
('CWF003', 'Valor de cada accion del proyecto Crowdfunding Adastra Rocket', '1', '2016-12-21 00:00:00', 'dba'),
('CWF004', 'Fecha de inicio del Crowdfunding PNG', '2017-10-10', '2016-12-23 00:00:00', 'dba'),
('CWF005', 'Dias para liquidar operaciones de Crowdfunding PNG', '1', '2017-10-10 00:00:00', 'dba'),
('CWF006', 'Monto de inversion minima SERIE A', '1000000', '2017-10-10 00:00:00', 'dba'),
('CWF007', 'Monto de inversion minima SERIE B', '500000', '2017-10-10 00:00:00', 'dba'),
('CWF008', 'Monto de inversion minima SERIE C', '1', '2017-10-10 00:00:00', 'dba'),
('CWF009', 'Fecha pago de los bonos por parte de TSE', '2018-08-13', '2017-10-10 00:00:00', 'dba'),
('LEN001', 'Denominaciones de operaciones colones (Múltiplos)', '1000000', '0000-00-00 00:00:00', ''),
('LEN002', 'Denominaciones de operaciones dólares (Múltiplos)', '1000', '0000-00-00 00:00:00', ''),
('LEN003', 'Plazo mínimo de préstamos en meses', '6', '0000-00-00 00:00:00', ''),
('LEN004', 'Plazo máximo de préstamos en meses', '60', '0000-00-00 00:00:00', ''),
('PRM001', 'Valor de multiplos para certificados inv en colones', '100000', '2018-08-06 00:00:00', 'dba'),
('PRM002', 'Valor de multiplos para certificados inv en dolares', '200', '2018-08-06 00:00:00', 'dba'),
('SIS001', 'Parámetro que almacena el valor de la comisión por transferencias en DOLARES (2 US$)', '2', '2017-12-11 00:00:00', 'Jose Rivas'),
('SIS002', 'Almacena el prefijo del banco desde donde se hacen las transferencias (BNCR)', '151', '2016-06-01 00:00:00', 'dba'),
('SIS003', 'Disclaimer en los correos automáticos', ' Este mensaje junto con cualquier archivo adjunto puede contener información confidencial propiedad de MASTERZON CR S.A. El uso o difusión de la información está sujeta a las regulaciones de privacidad, confidencialidad, responsabilidad y protección que apliquen a las personas y asuntos aludidos directa o indirectamente, a personas internas u otras personas no directamente interesadas o involucradas. La divulgación, distribución, reproducción o utilización del contenido de esta comunicación, ya sea total o parcialmente es estrictamente prohibida y puede dar lugar a responsabilidades legales.', '0000-00-00 00:00:00', ''),
('SIS004', 'Hora de cambio de sesión .***SOLO PERMITE HORAS EXACTAS*** EJ: 17:00:00', '10:00:00', '2018-07-20 20:54:48', 'Francisco Ulate Azofeifa'),
('SIS005', 'DSICLAIMER de boleta de venta', 'Los datos de negociación indicados en este ticker pueden variar según lo que se indique en el documento de reglas de negocio.', '2016-11-14 00:00:00', 'dba'),
('SIS006', 'Disclaimer sobre DISCREPANCIAS   ', 'Cualquier discrepancia en los datos de la transacción descritos en esta boleta de liquidación, se deben reportar a MASTERZON CR a más tardar 3 días hábiles a partir de la fecha de la operación.', '2016-11-14 00:00:00', 'dba'),
('SIS007', 'Correo del destinatario de LEXINCORP para envío de boletas de liquidación de MASTERZON', 'atatrust@andretinoco.com', '2017-11-24 00:00:00', 'Gerson'),
('SIS008', 'Cuerpo del correo de boleta vendedor en formato HTML', '\'<html> 					<head> 					   <title>Masterzon.com</title> 					</head> 					<body> 					<h1>Datos de la operación liquidada:</h1> 					<p>Estimado (a)\'.$nombre.\' \'.$apellido1.\' \'.$apellido2.\'</p> 					 			  		\'<p> Sirva la presenta comunicación para informarle sobre que la operaciones No. está siendo liquidada por el departamento de operaciones.</p>               		<p><hr> </p> 			  		 <p><b>.\'.$disclaimer.\'</b></p> 			  		<p> <a href=\"https://masterzon.com\"> <img src=\"http://www.waves-lab.net/images/logo_oficial_celeste.png\" alt=\"logo\"> </a>  </p> 			  		<p><hr> </p>                      </body> 					</html> 					\'', '2016-11-14 00:00:00', 'dba'),
('SIS009', 'cuerpo del correo de boleta comprador EN FORMATO html', '\'<html> 					<head> 					   <title>Masterzon.com</title> 					</head> 					<body> 					<h1>Datos de la operación liquidada:</h1> 					<p>Estimado (a)\'.$nombre.\' \'.$apellido1.\' \'.$apellido2.\'</p> 					 			  		\'<p> Sirva la presenta comunicación para informarle sobre que la operaciones No. está siendo liquidada por el departamento de operaciones.</p>               		<p><hr> </p> 			  		 <p><b>.\'.$disclaimer.\'</b></p> 			  		<p> <a href=\"https://masterzon.com\"> <img src=\"http://www.waves-lab.net/images/logo_oficial_celeste.png\" alt=\"logo\"> </a>  </p> 			  		<p><hr> </p>                      </body> 					</html> 					\'', '2016-11-14 00:00:00', 'dba'),
('SIS010', 'DSICLAIMER de boleta de compra', 'Los datos de negociación indicados en este ticker de compra pueden variar según lo que se indique en el documento de reglas de negocio.', '2016-11-14 00:00:00', 'dba'),
('SIS011', 'Hora de entrega', '15:00', '2018-05-02 00:00:00', 'Rafael Villalobos'),
('SIS012', 'Monto PORCENTUAL de comisión de FIDUCIARIA, para inversionistas (compradores).', '10', '0000-00-00 00:00:00', ''),
('SIS013', 'Monto PORCENTUAL de comisión de FIDUCIARIA, para proveedores (vendedores).', '0', '0000-00-00 00:00:00', ''),
('SIS014', 'Plazo mínimo en días naturales para descartar facturas.', '7', '2016-12-15 00:00:00', 'dba'),
('SIS015', 'Cantidad de minutos antes del vencimiento de la session', '60', '2017-02-08 00:00:00', 'dba'),
('SIS016', 'Nombre del representante legal de ATA Trust Company SA', 'Alonso Vargas Araya', '0000-00-00 00:00:00', ''),
('SIS017', 'Cedula del representante legal de ATA Trust Company SA', '1-0816-0243', '0000-00-00 00:00:00', ''),
('SIS018', 'Cuenta corriente en dolares de ATA Trust Company S.A ( BNCR)	', '100-02-095-600627-0', '0000-00-00 00:00:00', ''),
('SIS019', 'Cuenta cliente en dolares de ATA Trust Company S.A ( BNCR)		', '15109510026006273', '0000-00-00 00:00:00', ''),
('SIS020', 'Cuenta IBAN en dolares de  ATA Trust Company S.A ( BNCR)	', 'CR07015109510026006273', '0000-00-00 00:00:00', ''),
('SIS021', 'Cuenta corriente en colones de ATA Trust Company S.A ( BNCR)	', '100-01-080-007093-0', '0000-00-00 00:00:00', ''),
('SIS022', 'Cuenta cliente en colones de ATA Trust Company S.A ( BNCR)	', '15108010010070930', '0000-00-00 00:00:00', ''),
('SIS023', 'Cuenta IBAN en colones de ATA Trust Company S.A ( BNCR)	', 'CR86015108010010070930', '0000-00-00 00:00:00', ''),
('SIS024', 'Calidades del representante legal de ATA Trust Company SA', 'casado, abogado y notario, vecino de Barreal de Heredia,condominio Vía Indus 16C', '0000-00-00 00:00:00', ''),
('SIS025', 'Porcentaje de tipo de cambio de venta para  calculo de liquidaciones de operaciones multimoneda', '0.90', '2017-07-20 00:00:00', 'dba'),
('SIS026', 'Cantidad de días de margen para liquidar operaciones FACTORING (t+2)', '2', '0000-00-00 00:00:00', ''),
('SIS027', 'Almacena la alerta para la pizarra de Inversionistas', 'Nueva hora para cambio de Sesion 10:00 am', '2018-07-20 20:55:07', 'Francisco Ulate Azofeifa'),
('SIS028', 'Almacena la alerta para la pizarra de Proveedores', 'Nueva hora para cambio de Sesion 10:00 am', '2018-07-20 20:55:30', 'Francisco Ulate Azofeifa'),
('SIS029', 'Operacion actual en dashboard', '', '2018-07-20 13:49:40', 'Francisco Ulate Azofeifa'),
('SIS030', 'Parametro P/bloquear el acceso al parametro SIS029 (S= permite acceso / N = bloquea acceso)', 'S', '2018-06-14 00:00:00', 'GERSON');

-- --------------------------------------------------------

--
-- Table structure for table `sis_pujas_operaciones`
--

CREATE TABLE `sis_pujas_operaciones` (
  `cod_puja_operacion` int(15) NOT NULL,
  `cod_comprador` varchar(50) CHARACTER SET latin1 NOT NULL,
  `fec_hora_puja` datetime NOT NULL,
  `cod_estado` int(5) NOT NULL,
  `cod_vendedor` varchar(50) CHARACTER SET latin1 NOT NULL,
  `cod_venta` int(11) NOT NULL,
  `num_rendimiento` decimal(5,1) NOT NULL,
  `num_descuento` decimal(5,2) NOT NULL,
  `mon_transado` decimal(15,2) NOT NULL,
  `cod_usuario` varchar(50) CHARACTER SET latin1 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sis_pujas_operaciones_hist`
--

CREATE TABLE `sis_pujas_operaciones_hist` (
  `cod_puja_operacion` int(15) NOT NULL,
  `cod_venta` int(11) NOT NULL,
  `cod_comprador` varchar(50) NOT NULL,
  `num_rendimiento` decimal(5,2) NOT NULL,
  `num_descuento` decimal(5,2) NOT NULL,
  `mon_transado` decimal(15,2) NOT NULL,
  `cod_estado` int(5) NOT NULL,
  `cod_vendedor` varchar(50) NOT NULL,
  `num_rend_vendedor` decimal(5,2) DEFAULT '0.00',
  `cod_usuario` varchar(50) NOT NULL,
  `fec_hora_puja` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `sis_pujas_operaciones_privadas`
--

CREATE TABLE `sis_pujas_operaciones_privadas` (
  `cod_puja_operacion` int(15) NOT NULL,
  `cod_comprador` varchar(50) CHARACTER SET latin1 NOT NULL,
  `fec_hora_puja` datetime NOT NULL,
  `cod_estado` int(5) NOT NULL,
  `cod_vendedor` varchar(50) CHARACTER SET latin1 NOT NULL,
  `cod_venta` int(11) NOT NULL,
  `num_rendimiento` decimal(5,1) NOT NULL,
  `num_descuento` decimal(5,2) NOT NULL,
  `mon_transado` decimal(15,2) NOT NULL,
  `cod_usuario` varchar(50) CHARACTER SET latin1 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sis_pujas_operaciones_privadas_hist`
--

CREATE TABLE `sis_pujas_operaciones_privadas_hist` (
  `cod_puja_operacion` int(15) NOT NULL,
  `cod_venta` int(11) NOT NULL,
  `cod_comprador` varchar(50) NOT NULL,
  `num_rendimiento` decimal(5,2) NOT NULL,
  `num_descuento` decimal(5,2) NOT NULL,
  `mon_transado` decimal(15,2) NOT NULL,
  `cod_estado` int(5) NOT NULL,
  `cod_vendedor` varchar(50) NOT NULL,
  `num_rend_vendedor` decimal(5,2) DEFAULT '0.00',
  `cod_usuario` varchar(50) NOT NULL,
  `fec_hora_puja` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sis_pujas_operaciones_privadas_hist`
--

INSERT INTO `sis_pujas_operaciones_privadas_hist` (`cod_puja_operacion`, `cod_venta`, `cod_comprador`, `num_rendimiento`, `num_descuento`, `mon_transado`, `cod_estado`, `cod_vendedor`, `num_rend_vendedor`, `cod_usuario`, `fec_hora_puja`) VALUES
(1, 1, '152800006724', '10.00', '100.00', '140000.00', 4, '3101677940', '10.00', 'cbartels', '2018-11-08 12:57:15');

-- --------------------------------------------------------

--
-- Table structure for table `sis_secciones_contratos`
--

CREATE TABLE `sis_secciones_contratos` (
  `cod_tipo_contrato` int(5) NOT NULL,
  `cod_seccion_contrato` int(5) NOT NULL,
  `des_seccion_contrato` varchar(150) DEFAULT NULL,
  `des_texto_fijo_seccion` varchar(3000) DEFAULT NULL,
  `num_ordenamiento_secion` int(5) DEFAULT NULL,
  `usr_modificacion` varchar(50) NOT NULL,
  `fec_modificacion` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tablas que almacena las partes que componen un contrato y su orden.';

--
-- Dumping data for table `sis_secciones_contratos`
--

INSERT INTO `sis_secciones_contratos` (`cod_tipo_contrato`, `cod_seccion_contrato`, `des_seccion_contrato`, `des_texto_fijo_seccion`, `num_ordenamiento_secion`, `usr_modificacion`, `fec_modificacion`) VALUES
(1, 1, 'ENCABEZADO pag1', '<html><head> <link rel=\"stylesheet\" href=\"css/contratos/style.css\" media=\"all\" /> </head> <body> <header class=\"clearfix\"> <div id=\"company\" class=\"clearfix\" ><div align=\'right\'><font face=\"arial\" size=\"2\">Pág. 1 de 2<hr></font></div> <img src=\"images/enc_contrato_cesion.png\" width=\"860px\" /></div></header><main>', 1, 'dba', '2017-05-25 09:59:44'),
(1, 2, 'SUBTITULO DEL CONTRATO', '<p align=\'center\'><font face=\"arial\" size=\"5\"><b><u>CONTRATO DE CESIÓN PARA DESCUENTO DE FACTURAS DE LA OPERACION No. NOP </u></b></font></p>', 2, 'dba', '2017-05-25 09:59:44'),
(1, 3, 'PARRAFO #1', '<p align=\'justify\'><font face=\"arial\" size=\"4\">ESTE CONTRATO DE CESIÓN (en adelante “Contrato”) es suscrito el día FEC entre RSC cédula de persona jurídica número  CJR representada en este acto por NRL , mayor de edad, ECR , PRL vecino(a) de DRL , con número de identificación CRL en su condición de Gerente de la sociedad y con facultades de Apoderado Generalísimo sin límite de suma (en adelante “el Cedente”)  y ATA TRUST COMPANY, SOCIEDAD ANÓNIMA, cédula de persona jurídica número 3-101-387856, una sociedad debidamente autorizada por parte de la Superintendencia General de Entidades Financieras (SUGEF) para operar como Fiduciaria, representada en este acto por el señor RLA, mayor,  CRA  y portador de la cédula de identidad número CDA , en su condición de Apoderado Generalísimo sin límite de suma de la sociedad, de conformidad con las facultades del artículo 1253 del Código Civil, (en adelante “el Cesionario”), de forma conjunta denominados como las Partes;</font></p>', 3, 'dba', '2017-05-25 09:59:44'),
(1, 4, 'TITULO CONSIDERANDO', '<p align=\'center\'><font face=\"arial\" size=\"5\"><b><u>CONSIDERANDO:</u></b></font></p>', 4, 'dba', '2017-05-25 09:59:44'),
(1, 5, 'CONSIDERANDO #1', '<p align=\'justify\'><font face=\"arial\" size=\"4\"><b><u>PRIMERO</u></b>: Que el Cedente es el dueño de una factura a crédito, con un plazo de vencimiento a futuro;</font></p>', 5, 'dba', '2017-05-25 09:59:44'),
(1, 6, 'CONSIDERANDO #2', '<p align=\'justify\'><font face=\"arial\" size=\"4\"><b><u>SEGUNDO</u></b>: Que el Cedente, requiere el monto o pago de dicha factura en un corto plazo, para obtener liquidez y/o flujo de caja;</font></p>', 6, 'dba', '2017-05-25 09:59:44'),
(1, 7, 'CONSIDERANDO #3', '<p align=\'justify\'><font face=\"arial\" size=\"4\"><b><u>TERCERO</u></b>: Que para tal fin, el Cedente hará uso de la plataforma Masterzon por medio de la cual descontará la factura;</font></p>', 7, 'dba', '2017-05-25 09:59:44'),
(1, 8, 'CONSIDERANDO #4', '<p align=\'justify\'><font face=\"arial\" size=\"4\"><b><u>CUARTO</u></b>: Que Las Partes han suscrito un Contrato de Fideicmiso Sobre Entrega y Manejo de Factura y Envío de Fondos, para darle sustento a la transacción de descuento de facturas que se llevará a cabo por medio de la plataforma Masterzon.</font></p>', 8, 'dba', '2017-05-25 09:59:44'),
(1, 9, 'TITULO POR TANTO:', '<br><p align=\'center\'><font face=\"arial\" size=\"5\"><b><u>POR TANTO:</u></b></font></p>', 9, 'dba', '2017-05-25 09:59:44'),
(1, 10, 'POR TANTO PARRAFO #1', '<p align=\'justify\'><font face=\"arial\" size=\"4\">En virtud de las consideraciones anteriores y los respectivos acuerdos aquí detallados, Las Partes acuerdan celebrar el presente Contrato de Cesión de Facturas que será regido por los siguientes términos, condiciones y estipulaciones</font></p>', 10, 'dba', '2017-05-25 09:59:44'),
(1, 11, 'POR TANTO PARRAFO #2', '<p align=\'justify\'><font face=\"arial\" size=\"4\"><b>1. Cesión de créditos:</b> Que el Cedente, cede y traspasa en este acto al Cesionario, quien acepta, la factura comercial que se detalla a continuación, y los créditos que ésta representa, así como todos los derechos inherentes a la cesión no consignados en este documento, siendo consciente que la cesión es exclusivamente a favor del Cesionario, no pudiendo efectuar otra cesión a favor de tercero.</font> </p>', 11, 'dba', '2017-05-25 09:59:44'),
(1, 12, 'POR TANTO PARRAFO #3', '<p align=\'justify\'><font face=\"arial\" size=\"4\">Declara en este acto el Cedente, que no existen cesiones anteriores y que los créditos comerciales en este acto cedidos, no han sido cancelados parcial o totalmente, que todas estas representan ventas verdaderas, en firme y que en ningún caso se trata de ventas condicionales en consignación o depósito y que no existen vicios que impidan el buen pago al Cesionario. Las facturas comerciales y demás documentación original relacionada permanecerán en poder del Cesionario.</font></p>', 12, 'dba', '2017-05-25 09:59:44'),
(1, 13, 'ESPACIO DISPONIBLE', '<br><br><div align=\'right\'>.</div>', 13, 'dba', '2017-05-25 09:59:44'),
(1, 14, 'DETALLE DE LA FACTURA PARRAFO #1', '<br><br><p align=\'justify\'><font face=\"arial\" size=\"4\"><div align=\'right\'><font face=\"arial\" size=\"2\">Pág. 2 de 2<hr></font></div><b>2. Detalle de la factura:</b> La factura comercial cedida es la que se detalla a continuación, junto con los créditos que éstas representan, así como todos los derechos inherentes a la cesión no consignados en dicho documento:</font></p>', 14, 'dba', '2017-05-25 09:59:44'),
(1, 15, 'TABLA DETALLE DE LA FACTURA', '<table  style=\"width:70%\"><tr><td>Fecha de la Factura</td><td align=\'left\'> FFO </td></tr><tr><td>Número de la Factura</td><td align=\'left\'> NDO </td></tr><tr><td> Deudor </td><td align=\'left\'> DDO  </td></tr><tr><td> Cedula Jurídica </td><td align=\'left\'> CDO </td></tr><tr><td> Monto de la Factura </td><td align=\'left\'> MFO </td></tr><tr><td> Moneda </td><td align=\'left\'> MOP </td></tr><tr><td> ABC</td><td align=\'left\'> XYZ </td></tr></table>', 15, 'dba', '2017-05-25 09:59:44'),
(1, 16, 'DETALLE DE LA FACTURA PARRAFO #2', '<p align=\'justify\'><font face=\"arial\" size=\"4\">El Cedente acepta expresamente, que al momento del pago de la factura, en caso de que el monto retenido por el Deudor sea mayor al monto no descontado por el Cesionario, reintegrar al Cesionario la cifra monetaria resultante de restar al monto retenido por el Deudor, el monto no descontado por el Cesionario, de tal forma que garantice, la devolución total del patrimonio otorgado por el Cesionario al Cedente, más los intereses correspondientes. </font></p>', 16, 'dba', '2017-05-25 09:59:44'),
(1, 17, 'DETALLE DE 3. Fianza solidaria', '<p align=\'justify\'><font face=\"arial\" size=\"4\"><b>3. Fianza solidaria:</b> El Cedente garantiza al Cesionario, no solo la validez y existencia de los créditos comerciales cedidos en virtud de este Contrato, sino también la solvencia del deudor o su efectivo pago, constituyéndose por tanto en fiador solidario, de la persona física o jurídica que figura como deudor de cada uno de los créditos comerciales cedidos, por lo que, en caso de falta de pago por parte del Deudor, del monto indicado en la  factura cedida; el Cesionario podrá llevar a cabo el cobro respectivo al Cedente, quien tendrá la obligación de pagar el monto respectivo, en virtud que esta cesión se hace con recurso. Tomando en consideración que esta Cesión de Factura se lleva a cabo como parte de la transacción de Descuento de Factura que el Cedente está efectuando por medio de la plataforma Masterzon, se deja constancia y así lo acepta el Cedente, que caso dado en que el deudor u obligado al pago de la factura cedida no proceda con el pago de la misma a su vencimiento, el Cesionario tendrá la facultad de ceder la factura a un tercero de su libre escogencia, para que éste proceda al cobro y trámite respectivo de la factura. </font></p>', 17, 'dba', '2017-05-25 09:59:44'),
(1, 18, 'DETALLE DE 4. Cuentas', '<p align=\'justify\'><font face=\"arial\" size=\"4\"><b>4. Cuentas:</b> En vista del presente contrato de cesión, las Partes dejamos constancia que los dineros correspondientes a la factura supra descrita, deben de ser depositados en la cuenta bancaria segun corresponda, a nombre de “ATA TRUST COMPANY S.A”, cédula de persona jurídica número 3-101-387856, en el Banco Nacional de Costa Rica.  Notifíquese el pago a los siguientes correos electrónicos: info@masterzon.com y atatrust@andretinoco.com</font></p> <div class=\"col-md-6\"> <div class=\"panel panel-default\"> <div class=\"panel-heading\">                        </div><div class=\"panel-body\"><div class=\"table-responsive\">                                <table class=\"table\">                                    <thead>                                        <tr> <th>Moneda</th>                                            <th>No. Cuenta</th>                                            <th>No. Cuenta cliente</th>                                            <th>No. Cuenta IBAN</th></tr>                                    </thead>                                    <tbody>                                        <tr>                                            <td>Colones C.R.</td>                                            <td> CSA </td>                                            <td> CCA </td>                                            <td> ICA </td>                                        </tr>                                        <tr>                                            <td>U.S. Dólares</td>                                            <td> DSA </td>                                            <td> CDA </td>                                            <td> IDA </td>                                        </tr>                                                                           </tbody>                                </table>                            </div>                        </div>                    </div>                       </div>', 18, 'dba', '2017-05-25 09:59:44'),
(1, 19, 'DETALLE DE 5. Poder Especial y Autorización', '<p align=\'justify\'><font face=\"arial\" size=\"4\"><b>5. Poder Especial y Autorización:</b> En este acto, el Cesionario otorga autorización y poder especial, de conformidad con el artículo 1256 del Código Civil, al señor: José Napoleón Rivas Ramírez, portador de la cédula de identidad número 2-644-727, o bien a quien se designe en su lugar mediante poder especial, para que proceda a acudir ante las oficinas del deudor u obligado al pago de la factura, con el fin de notificarle la presente Cesión de la factura, así como para proceder a la gestión del cobro y pago efectivo de la misma. </font></p>', 19, 'dba', '2017-05-25 09:59:44'),
(1, 20, 'CONCLUSION', '<p align=\'justify\'><font face=\"arial\" size=\"4\">EN FE DE LO ANTERIOR, las Partes suscriben el presente Contrato en la ciudad de San José, en la fecha <b>arriba indicada</b>.</font></p><br>', 20, 'dba', '2017-05-25 09:59:44'),
(1, 22, 'NOMBRE DEL RESPONSABLE ATA TRUST', '<table  style=\"width:95%\">	<tr><td align=\'left\'>FIRMA:________________________</td><td align=\'right\'>FIRMA:________________________</td></tr>\n			<tr><td align=\'left\'>P/ RSC</td><td align=\'right\'> P/ ATA TRUST COMPANY S.A. </td></tr>\n			<tr><td align=\'left\'> NRL </td><td align=\'right\'> NOMBRE:________________________</td></tr>\n			<tr><td align=\'left\'> EL CEDENTE </td><td align=\'right\'> EL CESIONARIO </td></tr>			\n</table>', 22, 'dba', '2017-05-25 09:59:44'),
(1, 23, 'PIE DE PAGINA', '</main><footer>“La inscripción de Ata Trust Company S.A, cédula jurídica número 3-101-387856, ante la Superintendencia General de Entidades Financieras no es una autorización para operar, y la supervisión que ejerce esa Superintendencia es sólo en materia de legitimación de capitales según lo dispuesto en la Ley 8204, “Ley sobre estupefacientes, sustancias psicotrópicas, drogas de uso no autorizado, actividades conexas, legitimación de capitales y financiamiento al terrorismo.”</footer>  </body> </html>', 23, 'dba', '2017-05-25 09:59:44'),
(2, 1, 'ENCABEZADO Letra Cambio', '<html><head> <link rel=\"stylesheet\" href=\"css/contratos/style.css\" media=\"all\" /> </head> <body> <header class=\"clearfix\"> <div id=\"company\" class=\"clearfix\" ><div align=\'right\'><font face=\"arial\" size=\"2\">Pág. 1 de 1<hr></font></div> <img src=\"images/enc_contrato_cesion.png\" width=\"860px\" /></div></header><main>', 1, 'dba', '2018-02-01 09:59:44'),
(2, 2, 'SUBTITULO LETRA CAMBIO', '<body><br> <br> <h1>LETRA DE CAMBIO No. NOP - YYY </h1>', 2, 'dba', '2018-02-01 09:59:44'),
(2, 3, 'SUBTITULO MONTO', '<h2>  Por: MDA MTO </h2>', 3, 'dba', '2018-02-01 09:59:44'),
(2, 4, 'PARRAFO 1', '<br> <p align=\'justify\'><font face=\"arial\" size=\"4\"> El día DDD de MMM del YYY , se servirán <b> CTE </b> titular de la cédula jurídica número <b> CED </b>, conocido como el DEUDOR, así como <b> RSC </b> mayor, ECR, PRF vecino(a) de DIR, con número de identificación CRL, conocido como <b>CODEUDOR</b>, pagar por esta LETRA DE CAMBIO, a la orden de <b>ATA TRUST COMPANY S.A.</b>, cédula de persona jurídica número <b> 3-101-387856 </b>, la cantidad de MDA MTO, con intereses corrientes y moratorios del RND % anual, en la cuenta bancaria en colones número S21 , número de cuenta cliente S22 a nombre de <b>ATA Trust Company, S.A.</b>, en el Banco Nacional de Costa Rica. Notifíquese el pago a los siguientes correos electrónicos: info@masterzon.com y atatrust@andretinoco.com</font> </p>', 4, 'dba', '2018-02-01 09:59:44'),
(2, 5, 'PARRAFO 2', ' <p align=\'justify\'><font face=\"arial\" size=\"4\"> Tanto el librador como el librado, endosante y avalista, tienen por renunciados el domicilio, los requerimientos de pago, los trámites que sean  renunciables de la ejecución judicial y las diligencias de protesto por falta de aceptación de pago, quedando además autorizada la concesión de prórrogas sin consulta de notificación. Tanto el librado y el librador, así como el avalista , señalan para recibir notificaciones, las oficinas de Lexincorp Abogados, en San Pedro de Montes de Oca, barrio Los Yoses, Avenida 10, Calle 37, oficinas a mano derecha con columnas de ladrillo.</font> </p>', 5, 'dba', '2018-02-01 09:59:44'),
(2, 6, 'LUGAR Y FECHA', '<br> <p align=\'justify\'><font face=\"arial\" size=\"4\">  Lugar y fecha de emisión: San José, Costa Rica, DIA DDD de MMM de YYY .</font> </p>', 6, 'dba', '2018-02-01 09:59:44'),
(2, 7, 'EL LIBRADO', ' <BR><br> <BR><br><table  style=\"width:100%\">\r\n<tr><td align=\'left\'>Firma:____________________</td>  <td  align=\'right\'>Firma:____________________</td> </tr>\r\n<tr><td align=\'left\'>P/ CTE </td> <td align=\'right\'> RLG </td></tr>\r\n <tr><td align=\'left\'> RSC</td>  <td align=\'right\'> AVALISTA</td></tr>\r\n <tr><td align=\'left\'> Documento de identidad CED </td> <td  align=\'right\'>Firma:____________________</td>    </tr>\r\n <tr><td align=\'left\'> EL LIBRADO </td> <td  align=\'right\'>Nombre:____________________</td> </tr>	\r\n <tr><td align=\'left\'> . </td>  <td align=\'right\'> AVALISTA</td></tr>		\r\n </table>\r\n\r\n</body>', 7, 'dba', '2018-02-01 09:59:44'),
(3, 1, 'ENCABEZADO FACTURA ESTANDAR', '<!DOCTYPE html>\r\n<html lang=\"es\">\r\n  <head>\r\n    <meta charset=\"charset=iso-8859-1\">\r\n    <title>Factura estandar</title>\r\n    <link rel=\"stylesheet\" type=\"text/css\" href=\"https://masterzon.com/css/facturas/style.css\" />\r\n  </head>\r\n  <body>\r\n    <header class=\"clearfix\">\r\n      <div id=\"logo\">\r\n        <img src=\"ICO\">\r\n      </div>\r\n      <div id=\"company\">\r\n        <h2 class=\"name\"> RSP </h2>\r\n        <div>DRP</div>\r\n       \r\n        <div><a href=\"\">EMP</a></div>\r\n      </div>\r\n      </div>\r\n    </header>', 1, 'dba', '2018-02-21 15:02:36'),
(3, 2, 'TITULO DE FACTURA', '<main>\r\n      <div id=\"details\" class=\"clearfix\">\r\n        <div id=\"client\">\r\n          <div class=\"to\">FACTURADO A:</div>\r\n          <h2 class=\"name\">RLV</h2>\r\n          <div class=\"address\">DRV</div>\r\n          <div class=\"email\"><a href=\"\">EMV</a></div>\r\n        </div>\r\n        <div id=\"invoice\">\r\n          <h1>FACTURA # DCT</h1>\r\n          <div class=\"date\">Fecha de emision: FEM</div>\r\n          <div class=\"date\">Fecha estimada de pago: FEP</div>\r\n        </div>\r\n      </div>', 2, 'dba', '2018-02-21 15:02:36'),
(3, 3, 'DETALLE DE FACTURA', '<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n         <thead>\r\n           <tr>\r\n             <th class=\"no\">#</th>\r\n             <th class=\"desc\">DESCRIPCION</th>\r\n             <th class=\"unit\">MONTO FACIAL UNITARIO</th>\r\n             <th class=\"qty\">FRACCIONES</th>\r\n             <th class=\"total\">FACIAL TOTAL</th>\r\n           </tr>\r\n         </thead>\r\n         <tbody>\r\n           <tr>\r\n             <td class=\"no\">01</td>\r\n             <td class=\"desc\"><h3>(Tipo)</h3>TPO</td>\r\n             <td class=\"unit\">MDA FCL</td>\r\n             <td class=\"qty\">1 de CFC </td>\r\n             <td class=\"total\">MDA FLT</td>\r\n           </tr>\r\n           <tr>\r\n             <td class=\"no\"></td>\r\n             <td class=\"desc\"><h3> </h3></td>\r\n             <td class=\"unit\"> </td>\r\n             <td class=\"qty\"></td>\r\n             <td class=\"total\"> </td>\r\n           </tr>\r\n         </tbody>\r\n         <tfoot>\r\n           <tr>\r\n             <td colspan=\"2\"></td>\r\n             <td colspan=\"2\">GRAN TOTAL</td>\r\n             <td>MDA FLT </td>\r\n           </tr>\r\n         </tfoot>\r\n       </table>', 3, 'dba', '2018-02-21 15:03:30'),
(3, 4, 'PIE DE PAGINA FACTURA', '<div id=\"thanks\"></div>     \r\n <div id=\"notices\">\r\n        <div>NOTAS:</div>\r\n    <div class=\"notice\">La presente factura se cancelará en un plazo estimado de PLZ días. </div>\r\n    <div class=\"notice\">Este tiquete, es un resumen de factura y no constituye Título Ejecutivo (validado por Masterzon CR S.A.).</div>\r\n    <div class=\"notice\">Entidad tributaria: Dirección General de Tributación Directa de Costa Rica.</div>\r\n      </div>\r\n    </main>\r\n  <footer>\r\n      Pag 1 de 1\r\n     </footer>\r\n  </body>\r\n</html>', 4, 'dba', '2018-02-21 15:03:30');

-- --------------------------------------------------------

--
-- Table structure for table `sis_tipos_contratos`
--

CREATE TABLE `sis_tipos_contratos` (
  `cod_tipo_contrato` int(5) NOT NULL,
  `des_tipo_contrato` varchar(50) DEFAULT NULL,
  `usr_modificacion` varchar(50) NOT NULL,
  `fec_modificacion` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla que almacena los diferentes tipos de contratos en Masterzon';

--
-- Dumping data for table `sis_tipos_contratos`
--

INSERT INTO `sis_tipos_contratos` (`cod_tipo_contrato`, `des_tipo_contrato`, `usr_modificacion`, `fec_modificacion`) VALUES
(1, 'Contrato de cesión para descuento de facturas', 'dba', '0000-00-00 00:00:00'),
(2, 'Letra de cambio para proveedores FACTORING', 'dba', '0000-00-00 00:00:00'),
(3, 'Facturas estandar', 'dba', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `sis_tipos_identificaciones`
--

CREATE TABLE `sis_tipos_identificaciones` (
  `cod_tipo_identificacion` int(2) NOT NULL,
  `des_tipo_identificacion` varchar(50) NOT NULL,
  `ind_tipo_identificacion` varchar(1) NOT NULL,
  `fec_creacion` date NOT NULL,
  `cod_usuario_creacion` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf16 COMMENT='Tabla que almacena los tipos de identificaciones permitidas en el sistema';

--
-- Dumping data for table `sis_tipos_identificaciones`
--

INSERT INTO `sis_tipos_identificaciones` (`cod_tipo_identificacion`, `des_tipo_identificacion`, `ind_tipo_identificacion`, `fec_creacion`, `cod_usuario_creacion`) VALUES
(1, 'Fisica', 'F', '2016-05-03', 'gerson78'),
(2, 'Juridico', 'J', '2016-05-03', 'gerson78');

-- --------------------------------------------------------

--
-- Table structure for table `sis_tipos_monedas`
--

CREATE TABLE `sis_tipos_monedas` (
  `cod_tipo_moneda` int(5) NOT NULL,
  `des_tipo_moneda` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci NOT NULL,
  `des_nombre` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci NOT NULL,
  `mon_facial_minima` double(20,2) NOT NULL,
  `mon_comision_minima` double(20,2) NOT NULL,
  `fec_modificacion` date NOT NULL,
  `usr_modificacion` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tabla que registra las monedas permitidas en el sistema, y el factor de convers.';

--
-- Dumping data for table `sis_tipos_monedas`
--

INSERT INTO `sis_tipos_monedas` (`cod_tipo_moneda`, `des_tipo_moneda`, `des_nombre`, `mon_facial_minima`, `mon_comision_minima`, `fec_modificacion`, `usr_modificacion`) VALUES
(1, 'CRC', 'Colones Costarricenses', 2500000.00, 25000.00, '2016-11-15', '来牳潮㜸'),
(2, 'US$', 'Dolares americanos', 5000.00, 50.00, '2016-11-15', '来牳潮㜸'),
(3, 'Pesos', 'Pesos mexicanos', 10.00, 10.00, '2016-11-16', ''),
(4, 'Euros', 'Euros', 10.00, 10.00, '2016-11-16', '');

-- --------------------------------------------------------

--
-- Table structure for table `sis_tipos_periodicidades`
--

CREATE TABLE `sis_tipos_periodicidades` (
  `cod_tipo_periodicidad` int(5) NOT NULL,
  `num_periodicidad` int(2) NOT NULL,
  `des_periodicidad` varchar(50) NOT NULL,
  `fec_creacion` date NOT NULL,
  `cod_usuario_creacion` varchar(50) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='Tabla que almacena los tipos de periodicidades';

--
-- Dumping data for table `sis_tipos_periodicidades`
--

INSERT INTO `sis_tipos_periodicidades` (`cod_tipo_periodicidad`, `num_periodicidad`, `des_periodicidad`, `fec_creacion`, `cod_usuario_creacion`) VALUES
(1, 12, 'Mensual', '2017-01-09', 'dba'),
(2, 6, 'Bimensual', '2017-01-09', 'dba'),
(3, 4, 'Trimestral', '2017-01-09', 'dba'),
(4, 3, 'Cuatrimestral', '2017-01-10', 'dba'),
(6, 1, 'Anual', '2017-01-09', 'dba'),
(5, 2, 'Semestral', '2017-01-23', 'dba');

-- --------------------------------------------------------

--
-- Table structure for table `sis_tipos_sectores`
--

CREATE TABLE `sis_tipos_sectores` (
  `cod_sector` int(5) NOT NULL,
  `des_sector` varchar(150) DEFAULT NULL,
  `fec_modificacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `usr_modificacion` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla que almacena los sectores que aglomeran las empresas e instituciones';

--
-- Dumping data for table `sis_tipos_sectores`
--

INSERT INTO `sis_tipos_sectores` (`cod_sector`, `des_sector`, `fec_modificacion`, `usr_modificacion`) VALUES
(0, 'No definido', '2018-01-31 12:52:14', 'gre'),
(1, 'PUBLICO', '2017-06-15 12:38:19', 'dba'),
(2, 'PRIVADO', '2017-06-15 12:38:19', 'dba');

-- --------------------------------------------------------

--
-- Table structure for table `sis_tipo_cambio_monedas`
--

CREATE TABLE `sis_tipo_cambio_monedas` (
  `fec_tipo_cambio` date NOT NULL,
  `cod_moneda` int(3) NOT NULL,
  `cod_fuente` int(5) NOT NULL,
  `num_valor` decimal(20,10) NOT NULL,
  `num_valor_compra` decimal(20,10) NOT NULL,
  `fec_modificacion` date NOT NULL,
  `cod_usuario_modificacion` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tabla que almacena tipos de camio de diferentes fuentes';

--
-- Dumping data for table `sis_tipo_cambio_monedas`
--

INSERT INTO `sis_tipo_cambio_monedas` (`fec_tipo_cambio`, `cod_moneda`, `cod_fuente`, `num_valor`, `num_valor_compra`, `fec_modificacion`, `cod_usuario_modificacion`) VALUES
('2017-03-07', 1, 1, '567.4000000000', '0.0000000000', '2017-03-07', 'Gerson'),
('2017-03-09', 2, 4, '567.0000000000', '0.0000000000', '2017-03-09', 'Gerson'),
('2017-03-10', 1, 1, '568.0000000000', '0.0000000000', '2017-03-10', 'Jose Rivas'),
('2017-03-10', 2, 4, '568.0000000000', '0.0000000000', '2017-03-10', 'Jose Rivas'),
('2017-03-21', 2, 4, '564.0700000000', '561.5600000000', '2017-03-21', 'Jose Rivas'),
('2017-03-22', 2, 1, '564.0400000000', '551.0400000000', '2017-03-22', 'Jose Rivas'),
('2017-04-03', 2, 1, '565.0000000000', '554.4700000000', '2017-04-03', 'Gerson'),
('2017-04-03', 2, 2, '567.3600000000', '554.4700000000', '2017-04-03', 'Jose Rivas'),
('2017-04-03', 2, 4, '567.3600000000', '560.3600000000', '2017-04-03', 'Gerson'),
('2017-04-04', 1, 4, '563.9300000000', '0.0000000000', '2017-04-05', 'Jose Rivas'),
('2017-04-04', 2, 4, '567.6200000000', '555.0000000000', '2017-04-05', 'Jose Rivas'),
('2017-04-05', 1, 0, '563.9300000000', '0.0000000000', '2017-04-06', 'Jose Rivas'),
('2017-04-05', 2, 4, '568.1300000000', '555.4600000000', '2017-04-05', 'Jose Rivas'),
('2017-04-06', 1, 0, '565.0900000000', '0.0000000000', '2017-04-06', 'Jose Rivas'),
('2017-04-06', 2, 0, '568.7900000000', '556.1400000000', '2017-04-06', 'Jose Rivas'),
('2017-04-07', 1, 0, '564.1700000000', '0.0000000000', '2017-04-07', 'Jose Rivas'),
('2017-04-07', 2, 0, '568.9900000000', '556.3600000000', '2017-04-07', 'Jose Rivas'),
('2017-04-17', 1, 0, '561.2900000000', '0.0000000000', '2017-04-18', 'Jose Rivas'),
('2017-04-17', 2, 0, '568.2000000000', '555.3600000000', '2017-04-18', 'Jose Rivas'),
('2017-04-18', 1, 0, '560.9500000000', '0.0000000000', '2017-04-18', 'Jose Rivas'),
('2017-04-18', 2, 0, '567.7000000000', '555.1200000000', '2017-04-18', 'Jose Rivas'),
('2017-04-19', 1, 0, '561.1500000000', '0.0000000000', '2017-04-19', 'Jose Rivas'),
('2017-04-19', 2, 0, '567.6200000000', '554.8800000000', '2017-04-19', 'Jose Rivas'),
('2017-04-20', 1, 0, '562.0500000000', '0.0000000000', '2017-04-20', 'Jose Rivas'),
('2017-04-20', 2, 0, '567.6700000000', '554.8000000000', '2017-04-20', 'Jose Rivas'),
('2017-04-21', 1, 0, '562.7500000000', '0.0000000000', '2017-04-24', 'Jose Rivas'),
('2017-04-21', 2, 0, '567.6700000000', '554.8500000000', '2017-04-24', 'Jose Rivas'),
('2017-04-24', 1, 0, '563.3400000000', '0.0000000000', '2017-04-24', 'Jose Rivas'),
('2017-04-24', 2, 0, '567.6700000000', '554.8500000000', '2017-04-24', 'Jose Rivas'),
('2017-04-25', 1, 0, '564.5000000000', '0.0000000000', '2017-04-27', 'Jose Rivas'),
('2017-04-25', 2, 0, '567.8800000000', '555.1900000000', '2017-04-27', 'Jose Rivas'),
('2017-04-26', 1, 0, '564.5000000000', '0.0000000000', '2017-04-27', 'Jose Rivas'),
('2017-04-26', 2, 0, '568.5000000000', '555.7500000000', '2017-04-27', 'Jose Rivas'),
('2017-04-27', 1, 0, '565.8100000000', '0.0000000000', '2017-04-27', 'Jose Rivas'),
('2017-04-27', 2, 0, '569.5600000000', '556.7900000000', '2017-04-27', 'Jose Rivas'),
('2017-04-28', 1, 0, '567.1100000000', '0.0000000000', '2017-04-28', 'Jose Rivas'),
('2017-04-28', 2, 0, '570.6200000000', '557.8600000000', '2017-04-28', 'Jose Rivas'),
('2017-05-01', 1, 0, '566.9300000000', '0.0000000000', '2017-05-02', 'Jose Rivas'),
('2017-05-01', 2, 0, '570.7200000000', '557.9000000000', '2017-05-02', 'Jose Rivas'),
('2017-05-02', 2, 0, '570.7200000000', '557.9000000000', '2017-05-02', 'Jose Rivas'),
('2017-05-03', 1, 0, '567.5300000000', '0.0000000000', '2017-05-04', 'Jose Rivas'),
('2017-05-03', 2, 0, '571.1400000000', '558.4900000000', '2017-05-04', 'Jose Rivas'),
('2017-05-04', 1, 0, '567.4600000000', '0.0000000000', '2017-05-04', 'Jose Rivas'),
('2017-05-04', 2, 0, '571.5500000000', '558.8400000000', '2017-05-04', 'Jose Rivas'),
('2017-05-05', 1, 0, '569.5200000000', '0.0000000000', '2017-05-05', 'Jose Rivas'),
('2017-05-05', 2, 0, '572.0400000000', '559.4300000000', '2017-05-05', 'Jose Rivas'),
('2017-05-08', 1, 4, '570.0700000000', '0.0000000000', '2017-05-08', 'Jose Rivas'),
('2017-05-08', 2, 4, '573.5100000000', '560.9200000000', '2017-05-08', 'Jose Rivas'),
('2017-05-09', 1, 4, '570.7100000000', '0.0000000000', '2017-05-09', 'Jose Rivas'),
('2017-05-09', 2, 4, '574.4800000000', '561.8400000000', '2017-05-09', 'Jose Rivas'),
('2017-05-10', 1, 4, '572.6300000000', '0.0000000000', '2017-05-11', 'Jose Rivas'),
('2017-05-10', 2, 4, '576.3300000000', '563.1800000000', '2017-05-11', 'Jose Rivas'),
('2017-05-11', 1, 4, '573.2400000000', '0.0000000000', '2017-05-11', 'Jose Rivas'),
('2017-05-11', 2, 4, '576.7400000000', '564.1800000000', '2017-05-11', 'Jose Rivas'),
('2017-05-12', 1, 4, '573.7400000000', '0.0000000000', '2017-05-22', 'Jose Rivas'),
('2017-05-12', 2, 4, '576.7400000000', '564.1400000000', '2017-05-12', 'Jose Rivas'),
('2017-05-13', 2, 4, '577.0300000000', '564.4300000000', '2017-05-22', 'Jose Rivas'),
('2017-05-14', 2, 4, '577.0300000000', '564.4300000000', '2017-05-22', 'Jose Rivas'),
('2017-05-15', 1, 4, '574.8200000000', '0.0000000000', '2017-05-22', 'Jose Rivas'),
('2017-05-15', 2, 4, '577.0300000000', '564.4300000000', '2017-05-22', 'Jose Rivas'),
('2017-05-16', 1, 4, '576.1900000000', '0.0000000000', '2017-05-22', 'Jose Rivas'),
('2017-05-16', 2, 4, '577.3900000000', '564.8600000000', '2017-05-22', 'Jose Rivas'),
('2017-05-17', 1, 4, '578.2400000000', '0.0000000000', '2017-05-22', 'Jose Rivas'),
('2017-05-17', 2, 4, '578.9400000000', '566.3100000000', '2017-05-22', 'Jose Rivas'),
('2017-05-18', 1, 4, '580.3000000000', '0.0000000000', '2017-05-22', 'Jose Rivas'),
('2017-05-18', 2, 4, '581.9000000000', '569.2600000000', '2017-05-22', 'Jose Rivas'),
('2017-05-19', 1, 4, '582.4400000000', '0.0000000000', '2017-05-22', 'Jose Rivas'),
('2017-05-19', 2, 4, '583.3700000000', '570.7100000000', '2017-05-22', 'Jose Rivas'),
('2017-05-20', 2, 4, '586.4300000000', '573.8200000000', '2017-05-22', 'Jose Rivas'),
('2017-05-21', 2, 4, '586.4300000000', '573.8200000000', '2017-05-22', 'Jose Rivas'),
('2017-05-22', 1, 4, '586.1900000000', '0.0000000000', '2017-05-22', 'Jose Rivas'),
('2017-05-22', 2, 4, '586.4300000000', '573.8200000000', '2017-05-22', 'Jose Rivas'),
('2017-05-23', 1, 4, '586.1900000000', '0.0000000000', '2017-05-23', 'Jose Rivas'),
('2017-05-23', 2, 4, '590.5700000000', '577.9800000000', '2017-05-23', 'Jose Rivas'),
('2017-05-24', 1, 4, '595.2800000000', '0.0000000000', '2017-05-24', 'Gerson'),
('2017-05-24', 2, 4, '598.4900000000', '585.5600000000', '2017-05-24', 'Gerson'),
('2017-05-25', 1, 4, '587.4800000000', '0.0000000000', '2017-05-25', 'Jose Rivas'),
('2017-05-25', 2, 4, '598.4900000000', '585.5600000000', '2017-05-25', 'Jose Rivas'),
('2017-05-26', 2, 4, '574.0000000000', '574.0000000000', '2017-05-26', 'Jose Rivas'),
('2017-05-29', 1, 4, '577.4600000000', '0.0000000000', '2017-05-29', 'Jose Rivas'),
('2017-05-29', 2, 4, '587.2500000000', '574.0600000000', '2017-05-29', 'Jose Rivas'),
('2017-05-30', 2, 4, '587.2500000000', '574.0600000000', '2017-05-30', 'Jose Rivas'),
('2017-05-31', 2, 4, '587.2500000000', '574.0600000000', '2017-05-31', 'Jose Rivas'),
('2017-06-01', 2, 4, '576.8600000000', '564.2200000000', '2017-06-01', 'Jose Rivas'),
('2017-06-02', 2, 4, '575.6700000000', '562.7600000000', '2017-06-05', 'Jose Rivas'),
('2017-06-05', 2, 4, '575.4700000000', '562.7400000000', '2017-06-05', 'Jose Rivas'),
('2017-06-06', 2, 4, '575.4000000000', '562.8000000000', '2017-06-06', 'Jose Rivas'),
('2017-06-07', 2, 4, '575.4000000000', '562.7600000000', '2017-06-09', 'Jose Rivas R'),
('2017-06-08', 2, 4, '575.4000000000', '562.7600000000', '2017-06-09', 'Jose Rivas R'),
('2017-06-09', 2, 4, '575.4000000000', '562.7600000000', '2017-06-09', 'Jose Rivas R'),
('2017-06-13', 2, 4, '577.4800000000', '564.7500000000', '2017-06-13', 'Jose Rivas'),
('2017-06-14', 2, 4, '577.5300000000', '564.7100000000', '2017-06-14', 'Jose Rivas'),
('2017-06-15', 2, 4, '577.4500000000', '564.6500000000', '2017-06-15', 'Francisco Ulate Azofeifa'),
('2017-06-16', 2, 4, '577.4500000000', '564.6500000000', '2017-06-16', 'Francisco Ulate Azofeifa'),
('2017-06-19', 2, 4, '576.7800000000', '564.1200000000', '2017-06-23', 'Jose Rivas'),
('2017-06-20', 2, 4, '576.8300000000', '564.1800000000', '2017-06-20', 'Francisco Ulate Azofeifa'),
('2017-06-21', 2, 4, '577.3700000000', '564.6200000000', '2017-06-21', 'Francisco Ulate Azofeifa'),
('2017-06-22', 2, 4, '577.3900000000', '564.6500000000', '2017-06-22', 'Francisco Ulate Azofeifa'),
('2017-06-23', 2, 4, '577.3900000000', '564.6400000000', '2017-06-23', 'Jose Rivas'),
('2017-06-26', 2, 4, '577.3900000000', '564.5800000000', '2017-06-26', 'Jose Rivas'),
('2017-06-27', 2, 4, '577.3900000000', '564.5800000000', '2017-06-28', 'Jose Rivas'),
('2017-06-29', 2, 4, '575.7900000000', '563.0000000000', '2017-06-29', 'Jose Rivas'),
('2017-07-10', 2, 4, '574.8300000000', '569.3000000000', '2017-07-10', 'Jose Rivas'),
('2017-07-11', 2, 4, '575.4400000000', '568.5100000000', '2017-07-11', 'Jose Rivas'),
('2017-07-12', 2, 4, '575.0000000000', '569.9900000000', '2017-07-12', 'Jose Rivas'),
('2017-07-13', 2, 4, '575.0500000000', '569.8300000000', '2017-07-13', 'Jose Rivas'),
('2017-07-17', 2, 4, '574.5700000000', '568.2000000000', '2017-07-17', 'Jose Rivas'),
('2017-07-18', 2, 4, '574.9900000000', '568.3900000000', '2017-07-18', 'Jose Rivas'),
('2017-07-24', 2, 4, '575.2500000000', '568.9000000000', '2017-07-24', 'Jose Rivas'),
('2017-07-27', 2, 4, '575.0500000000', '568.7500000000', '2017-07-27', 'Francisco Ulate Azofeifa'),
('2017-07-28', 1, 4, '574.5800000000', '569.6800000000', '2017-07-28', 'Francisco Ulate Azofeifa'),
('2017-07-31', 1, 4, '575.1700000000', '568.8700000000', '2017-07-31', 'Francisco Ulate Azofeifa'),
('2017-08-01', 1, 4, '575.5900000000', '568.9600000000', '2017-08-01', 'Francisco Ulate Azofeifa'),
('2017-08-03', 1, 4, '576.6200000000', '570.3400000000', '2017-08-03', 'Francisco Ulate Azofeifa'),
('2017-08-03', 2, 4, '576.6200000000', '570.3400000000', '2017-08-03', 'Gerson'),
('2017-08-04', 2, 4, '577.6200000000', '571.5500000000', '2017-08-04', 'Francisco Ulate Azofeifa'),
('2017-08-07', 2, 4, '577.6200000000', '571.5000000000', '2017-08-07', 'Francisco Ulate Azofeifa'),
('2017-08-08', 2, 4, '577.9100000000', '570.4300000000', '2017-08-08', 'Francisco Ulate Azofeifa'),
('2017-08-09', 2, 4, '578.4400000000', '572.2600000000', '2017-08-09', 'Francisco Ulate Azofeifa'),
('2017-08-10', 2, 4, '579.3300000000', '573.7000000000', '2017-08-10', 'Francisco Ulate Azofeifa'),
('2017-08-11', 2, 4, '578.8300000000', '573.5400000000', '2017-08-11', 'Francisco Ulate Azofeifa'),
('2017-08-14', 2, 1, '582.0000000000', '570.0000000000', '2017-08-15', 'Gerson'),
('2017-08-14', 2, 4, '578.9100000000', '572.9700000000', '2017-08-14', 'Jose Rivas'),
('2017-08-16', 2, 1, '582.0000000000', '570.0000000000', '2017-08-16', 'Francisco Ulate Azofeifa'),
('2017-08-16', 2, 4, '578.6600000000', '572.8800000000', '2017-08-16', 'Jose Rivas'),
('2017-08-17', 2, 1, '582.0000000000', '570.0000000000', '2017-08-17', 'Francisco Ulate Azofeifa'),
('2017-08-17', 2, 4, '575.5000000000', '575.5000000000', '2017-08-17', 'Francisco Ulate Azofeifa'),
('2017-08-18', 2, 1, '581.0000000000', '569.0000000000', '2017-08-18', 'Francisco Ulate Azofeifa'),
('2017-08-18', 2, 4, '574.8600000000', '574.8600000000', '2017-08-18', 'Francisco Ulate Azofeifa'),
('2017-08-21', 2, 1, '581.0000000000', '568.0000000000', '2017-08-21', 'Francisco Ulate Azofeifa'),
('2017-08-21', 2, 4, '574.9000000000', '574.9000000000', '2017-08-21', 'Francisco Ulate Azofeifa'),
('2017-08-22', 2, 1, '581.0000000000', '569.0000000000', '2017-08-22', 'Francisco Ulate Azofeifa'),
('2017-08-22', 2, 4, '575.1300000000', '575.1300000000', '2017-08-22', 'Francisco Ulate Azofeifa'),
('2017-08-23', 2, 1, '581.0000000000', '569.0000000000', '2017-08-23', 'Jose Rivas'),
('2017-08-23', 2, 4, '574.7300000000', '574.7300000000', '2017-08-23', 'Jose Rivas'),
('2017-08-24', 2, 1, '581.0000000000', '569.0000000000', '2017-08-24', 'Francisco Ulate Azofeifa'),
('2017-08-24', 2, 4, '575.2400000000', '575.2400000000', '2017-08-24', 'Francisco Ulate Azofeifa'),
('2017-08-25', 2, 1, '581.0000000000', '569.0000000000', '2017-08-25', 'Francisco Ulate Azofeifa'),
('2017-08-25', 2, 4, '575.7000000000', '575.7000000000', '2017-08-25', 'Francisco Ulate Azofeifa'),
('2017-08-28', 2, 1, '581.0000000000', '569.0000000000', '2017-08-28', 'Jose Rivas'),
('2017-08-28', 2, 4, '574.6800000000', '574.6800000000', '2017-08-28', 'Jose Rivas'),
('2017-08-29', 2, 1, '581.0000000000', '569.0000000000', '2017-08-29', 'Francisco Ulate Azofeifa'),
('2017-08-29', 2, 4, '574.2500000000', '574.2500000000', '2017-08-29', 'Francisco Ulate Azofeifa'),
('2017-08-30', 2, 1, '581.0000000000', '569.0000000000', '2017-08-30', 'Francisco Ulate Azofeifa'),
('2017-08-30', 2, 4, '574.3600000000', '574.3600000000', '2017-08-30', 'Francisco Ulate Azofeifa'),
('2017-08-31', 2, 1, '581.0000000000', '569.0000000000', '2017-08-31', 'Francisco Ulate Azofeifa'),
('2017-08-31', 2, 4, '575.3500000000', '575.3500000000', '2017-08-31', 'Francisco Ulate Azofeifa'),
('2017-09-01', 2, 1, '582.0000000000', '570.0000000000', '2017-09-01', 'Jose Rivas'),
('2017-09-01', 2, 4, '576.7800000000', '576.7800000000', '2017-09-01', 'Jose Rivas'),
('2017-09-04', 2, 1, '582.0000000000', '570.0000000000', '2017-09-04', 'Francisco Ulate Azofeifa'),
('2017-09-04', 2, 4, '576.2300000000', '576.2300000000', '2017-09-04', 'Francisco Ulate Azofeifa'),
('2017-09-05', 2, 1, '582.0000000000', '570.0000000000', '2017-09-05', 'Jose Rivas'),
('2017-09-05', 2, 4, '577.6100000000', '577.6100000000', '2017-09-05', 'Jose Rivas'),
('2017-09-06', 2, 1, '583.0000000000', '571.0000000000', '2017-09-06', 'Francisco Ulate Azofeifa'),
('2017-09-06', 2, 4, '578.3900000000', '578.3900000000', '2017-09-06', 'Francisco Ulate Azofeifa'),
('2017-09-07', 2, 1, '584.0000000000', '572.0000000000', '2017-09-07', 'Francisco Ulate Azofeifa'),
('2017-09-07', 2, 4, '579.6100000000', '579.6100000000', '2017-09-07', 'Francisco Ulate Azofeifa'),
('2017-09-08', 2, 1, '584.0000000000', '572.0000000000', '2017-09-08', 'Francisco Ulate Azofeifa'),
('2017-09-08', 2, 4, '578.8700000000', '578.8700000000', '2017-09-08', 'Francisco Ulate Azofeifa'),
('2017-09-11', 2, 1, '584.0000000000', '571.0000000000', '2017-09-11', 'Jose Rivas'),
('2017-09-11', 2, 4, '0.0000000000', '578.7400000000', '2017-09-11', 'Jose Rivas'),
('2017-09-12', 2, 1, '584.0000000000', '572.0000000000', '2017-09-12', 'Francisco Ulate Azofeifa'),
('2017-09-12', 2, 4, '578.1900000000', '578.1900000000', '2017-09-12', 'Francisco Ulate Azofeifa'),
('2017-09-13', 2, 1, '584.0000000000', '572.0000000000', '2017-09-13', 'Jose Rivas'),
('2017-09-13', 2, 4, '578.0500000000', '578.0500000000', '2017-09-13', 'Jose Rivas'),
('2017-09-14', 2, 1, '584.0000000000', '572.0000000000', '2017-09-14', 'Francisco Ulate Azofeifa'),
('2017-09-14', 2, 4, '577.8000000000', '577.8000000000', '2017-09-14', 'Francisco Ulate Azofeifa'),
('2017-09-18', 2, 1, '583.0000000000', '571.0000000000', '2017-09-18', 'Francisco Ulate Azofeifa'),
('2017-09-18', 2, 4, '577.7700000000', '577.7700000000', '2017-09-18', 'Francisco Ulate Azofeifa'),
('2017-09-19', 2, 1, '583.0000000000', '571.0000000000', '2017-09-19', 'Francisco Ulate Azofeifa'),
('2017-09-19', 2, 4, '576.9400000000', '576.9400000000', '2017-09-19', 'Francisco Ulate Azofeifa'),
('2017-09-20', 2, 1, '582.0000000000', '570.0000000000', '2017-09-20', 'Francisco Ulate Azofeifa'),
('2017-09-20', 2, 4, '576.1600000000', '576.1600000000', '2017-09-20', 'Francisco Ulate Azofeifa'),
('2017-09-21', 2, 1, '582.0000000000', '570.0000000000', '2017-09-21', 'Francisco Ulate Azofeifa'),
('2017-09-21', 2, 4, '575.5400000000', '575.5400000000', '2017-09-21', 'Francisco Ulate Azofeifa'),
('2017-09-22', 2, 1, '582.0000000000', '570.0000000000', '2017-09-22', 'Francisco Ulate Azofeifa'),
('2017-09-22', 2, 4, '575.0000000000', '575.0000000000', '2017-09-22', 'Francisco Ulate Azofeifa'),
('2017-09-25', 2, 1, '582.0000000000', '569.0000000000', '2017-09-25', 'Francisco Ulate Azofeifa'),
('2017-09-25', 2, 4, '574.9000000000', '574.9000000000', '2017-09-25', 'Francisco Ulate Azofeifa'),
('2017-09-26', 2, 1, '581.0000000000', '569.0000000000', '2017-09-26', 'Francisco Ulate Azofeifa'),
('2017-09-26', 2, 4, '574.6800000000', '574.6800000000', '2017-09-26', 'Francisco Ulate Azofeifa'),
('2017-09-27', 2, 1, '579.0000000000', '567.0000000000', '2017-09-27', 'Francisco Ulate Azofeifa'),
('2017-09-27', 2, 4, '573.5800000000', '573.5800000000', '2017-09-27', 'Francisco Ulate Azofeifa'),
('2017-09-28', 2, 1, '579.0000000000', '566.0000000000', '2017-09-28', 'Francisco Ulate Azofeifa'),
('2017-09-28', 2, 4, '572.9900000000', '572.9900000000', '2017-09-28', 'Francisco Ulate Azofeifa'),
('2017-09-29', 2, 1, '578.0000000000', '565.0000000000', '2017-09-29', 'Jose Rivas'),
('2017-09-29', 2, 4, '571.9900000000', '571.9900000000', '2017-09-29', 'Jose Rivas'),
('2017-10-02', 2, 1, '578.0000000000', '566.0000000000', '2017-10-02', 'Francisco Ulate Azofeifa'),
('2017-10-02', 2, 4, '572.0300000000', '572.0300000000', '2017-10-02', 'Francisco Ulate Azofeifa'),
('2017-10-03', 2, 1, '578.0000000000', '566.0000000000', '2017-10-03', 'Francisco Ulate Azofeifa'),
('2017-10-03', 2, 4, '572.9300000000', '572.9300000000', '2017-10-03', 'Francisco Ulate Azofeifa'),
('2017-10-04', 2, 1, '578.0000000000', '566.0000000000', '2017-10-04', 'Francisco Ulate Azofeifa'),
('2017-10-04', 2, 4, '573.2100000000', '573.2100000000', '2017-10-04', 'Francisco Ulate Azofeifa'),
('2017-10-05', 2, 1, '579.0000000000', '567.0000000000', '2017-10-05', 'Francisco Ulate Azofeifa'),
('2017-10-05', 2, 4, '573.4000000000', '573.4000000000', '2017-10-05', 'Francisco Ulate Azofeifa'),
('2017-10-06', 2, 1, '580.0000000000', '568.0000000000', '2017-10-06', 'Francisco Ulate Azofeifa'),
('2017-10-06', 2, 4, '574.4900000000', '574.4900000000', '2017-10-06', 'Francisco Ulate Azofeifa'),
('2017-10-09', 2, 1, '580.0000000000', '568.0000000000', '2017-10-09', 'Francisco Ulate Azofeifa'),
('2017-10-09', 2, 4, '575.5500000000', '575.5500000000', '2017-10-09', 'Francisco Ulate Azofeifa'),
('2017-10-10', 2, 1, '580.0000000000', '568.0000000000', '2017-10-10', 'Francisco Ulate Azofeifa'),
('2017-10-10', 2, 4, '575.8400000000', '575.8400000000', '2017-10-10', 'Francisco Ulate Azofeifa'),
('2017-10-11', 2, 1, '580.0000000000', '568.0000000000', '2017-10-11', 'Francisco Ulate Azofeifa'),
('2017-10-11', 2, 4, '574.8200000000', '574.8200000000', '2017-10-11', 'Francisco Ulate Azofeifa'),
('2017-10-12', 2, 1, '580.0000000000', '568.0000000000', '2017-10-12', 'Francisco Ulate Azofeifa'),
('2017-10-12', 2, 4, '573.9000000000', '573.9000000000', '2017-10-12', 'Francisco Ulate Azofeifa'),
('2017-10-13', 2, 1, '579.0000000000', '567.0000000000', '2017-10-13', 'Francisco Ulate Azofeifa'),
('2017-10-13', 2, 4, '572.8800000000', '572.8800000000', '2017-10-13', 'Francisco Ulate Azofeifa'),
('2017-10-17', 2, 1, '577.0000000000', '565.0000000000', '2017-10-17', 'Francisco Ulate Azofeifa'),
('2017-10-17', 2, 4, '569.7800000000', '569.7800000000', '2017-10-17', 'Francisco Ulate Azofeifa'),
('2017-10-18', 2, 1, '576.0000000000', '564.0000000000', '2017-10-18', 'Francisco Ulate Azofeifa'),
('2017-10-18', 2, 4, '569.7700000000', '569.7700000000', '2017-10-18', 'Francisco Ulate Azofeifa'),
('2017-10-19', 2, 1, '576.0000000000', '564.0000000000', '2017-10-19', 'Francisco Ulate Azofeifa'),
('2017-10-19', 2, 4, '570.1000000000', '570.1000000000', '2017-10-19', 'Francisco Ulate Azofeifa'),
('2017-10-20', 2, 1, '576.0000000000', '564.0000000000', '2017-10-20', 'Jose Rivas'),
('2017-10-20', 2, 4, '570.9300000000', '570.9300000000', '2017-10-20', 'Francisco Ulate Azofeifa'),
('2017-10-23', 2, 1, '577.0000000000', '565.0000000000', '2017-10-23', 'Francisco Ulate Azofeifa'),
('2017-10-23', 2, 4, '571.0500000000', '571.0500000000', '2017-10-23', 'Francisco Ulate Azofeifa'),
('2017-10-24', 2, 1, '577.0000000000', '565.0000000000', '2017-10-24', 'Francisco Ulate Azofeifa'),
('2017-10-24', 2, 4, '570.0900000000', '570.0900000000', '2017-10-24', 'Francisco Ulate Azofeifa'),
('2017-10-25', 2, 1, '576.0000000000', '564.0000000000', '2017-10-25', 'Francisco Ulate Azofeifa'),
('2017-10-25', 2, 4, '569.5000000000', '569.5000000000', '2017-10-25', 'Francisco Ulate Azofeifa'),
('2017-10-26', 2, 1, '576.0000000000', '564.0000000000', '2017-10-26', 'Jose Rivas'),
('2017-10-26', 2, 4, '569.4800000000', '569.4800000000', '2017-10-26', 'Jose Rivas'),
('2017-10-27', 2, 1, '575.0000000000', '563.0000000000', '2017-10-27', 'Francisco Ulate Azofeifa'),
('2017-10-27', 2, 4, '569.2600000000', '569.2600000000', '2017-10-27', 'Francisco Ulate Azofeifa'),
('2017-10-30', 2, 1, '575.0000000000', '563.0000000000', '2017-10-30', 'Francisco Ulate Azofeifa'),
('2017-10-30', 2, 4, '569.6900000000', '569.6900000000', '2017-10-30', 'Francisco Ulate Azofeifa'),
('2017-10-31', 2, 1, '575.0000000000', '563.0000000000', '2017-10-31', 'Francisco Ulate Azofeifa'),
('2017-10-31', 2, 4, '570.1200000000', '570.1200000000', '2017-10-31', 'Francisco Ulate Azofeifa'),
('2017-11-01', 2, 1, '575.0000000000', '563.0000000000', '2017-11-01', 'Francisco Ulate Azofeifa'),
('2017-11-01', 2, 4, '569.8400000000', '569.8400000000', '2017-11-01', 'Francisco Ulate Azofeifa'),
('2017-11-02', 2, 1, '576.0000000000', '564.0000000000', '2017-11-02', 'Francisco Ulate Azofeifa'),
('2017-11-02', 2, 4, '570.1500000000', '570.1500000000', '2017-11-02', 'Francisco Ulate Azofeifa'),
('2017-11-02', 2, 9, '575.0000000000', '563.0000000000', '2017-11-02', 'Gerson'),
('2017-11-03', 2, 4, '570.1400000000', '570.1400000000', '2017-11-03', 'Francisco Ulate Azofeifa'),
('2017-11-03', 2, 9, '575.0000000000', '563.0000000000', '2017-11-03', 'Francisco Ulate Azofeifa'),
('2017-11-06', 2, 4, '570.2700000000', '570.2700000000', '2017-11-06', 'Francisco Ulate Azofeifa'),
('2017-11-06', 2, 9, '575.0000000000', '563.0000000000', '2017-11-06', 'Francisco Ulate Azofeifa'),
('2017-11-07', 2, 4, '570.2600000000', '570.2600000000', '2017-11-07', 'Francisco Ulate Azofeifa'),
('2017-11-07', 2, 9, '575.0000000000', '563.0000000000', '2017-11-07', 'Francisco Ulate Azofeifa'),
('2017-11-08', 2, 4, '570.5000000000', '570.5000000000', '2017-11-08', 'Francisco Ulate Azofeifa'),
('2017-11-08', 2, 9, '575.0000000000', '563.0000000000', '2017-11-08', 'Francisco Ulate Azofeifa'),
('2017-11-09', 2, 4, '570.5200000000', '570.5200000000', '2017-11-09', 'Francisco Ulate Azofeifa'),
('2017-11-09', 2, 9, '575.0000000000', '563.0000000000', '2017-11-09', 'Francisco Ulate Azofeifa'),
('2017-11-10', 2, 4, '569.9900000000', '569.9900000000', '2017-11-10', 'Francisco Ulate Azofeifa'),
('2017-11-10', 2, 9, '575.0000000000', '563.0000000000', '2017-11-10', 'Francisco Ulate Azofeifa'),
('2017-11-13', 2, 4, '569.5800000000', '569.5800000000', '2017-11-13', 'Francisco Ulate Azofeifa'),
('2017-11-13', 2, 9, '574.0000000000', '562.0000000000', '2017-11-13', 'Francisco Ulate Azofeifa'),
('2017-11-14', 2, 4, '569.1100000000', '569.1100000000', '2017-11-14', 'Francisco Ulate Azofeifa'),
('2017-11-14', 2, 9, '574.0000000000', '562.0000000000', '2017-11-14', 'Francisco Ulate Azofeifa'),
('2017-11-15', 2, 4, '569.1100000000', '569.1100000000', '2017-11-15', 'Francisco Ulate Azofeifa'),
('2017-11-15', 2, 9, '574.0000000000', '562.0000000000', '2017-11-15', 'Francisco Ulate Azofeifa'),
('2017-11-16', 2, 4, '568.0200000000', '568.0200000000', '2017-11-16', 'Francisco Ulate Azofeifa'),
('2017-11-16', 2, 9, '574.0000000000', '562.0000000000', '2017-11-16', 'Francisco Ulate Azofeifa'),
('2017-11-17', 2, 4, '567.2600000000', '567.2600000000', '2017-11-17', 'Francisco Ulate Azofeifa'),
('2017-11-17', 2, 9, '573.0000000000', '561.0000000000', '2017-11-17', 'Francisco Ulate Azofeifa'),
('2017-11-20', 2, 4, '566.2600000000', '566.2600000000', '2017-11-20', 'Francisco Ulate Azofeifa'),
('2017-11-20', 2, 9, '571.0000000000', '559.0000000000', '2017-11-20', 'Francisco Ulate Azofeifa'),
('2017-11-21', 2, 4, '565.7900000000', '565.7900000000', '2017-11-21', 'Francisco Ulate Azofeifa'),
('2017-11-21', 2, 9, '571.0000000000', '559.0000000000', '2017-11-21', 'Francisco Ulate Azofeifa'),
('2017-11-22', 2, 4, '566.4900000000', '566.4900000000', '2017-11-22', 'Francisco Ulate Azofeifa'),
('2017-11-22', 2, 9, '571.0000000000', '559.0000000000', '2017-11-22', 'Francisco Ulate Azofeifa'),
('2017-11-23', 2, 4, '566.4900000000', '566.4900000000', '2017-11-23', 'Francisco Ulate Azofeifa'),
('2017-11-23', 2, 9, '571.0000000000', '559.0000000000', '2017-11-23', 'Francisco Ulate Azofeifa'),
('2017-11-24', 2, 4, '566.1100000000', '566.1100000000', '2017-11-24', 'Francisco Ulate Azofeifa'),
('2017-11-24', 2, 9, '571.0000000000', '559.0000000000', '2017-11-24', 'Francisco Ulate Azofeifa'),
('2017-11-27', 2, 4, '566.4700000000', '566.4700000000', '2017-11-27', 'Francisco Ulate Azofeifa'),
('2017-11-27', 2, 9, '571.0000000000', '559.0000000000', '2017-11-27', 'Francisco Ulate Azofeifa'),
('2017-11-28', 2, 4, '566.1700000000', '566.1700000000', '2017-11-28', 'Francisco Ulate Azofeifa'),
('2017-11-28', 2, 9, '571.0000000000', '559.0000000000', '2017-11-28', 'Francisco Ulate Azofeifa'),
('2017-11-29', 2, 4, '566.2500000000', '566.2500000000', '2017-11-29', 'Francisco Ulate Azofeifa'),
('2017-11-29', 2, 9, '571.0000000000', '559.0000000000', '2017-11-29', 'Francisco Ulate Azofeifa'),
('2017-11-30', 2, 4, '566.2300000000', '566.2300000000', '2017-11-30', 'Francisco Ulate Azofeifa'),
('2017-11-30', 2, 9, '571.0000000000', '559.0000000000', '2017-11-30', 'Francisco Ulate Azofeifa'),
('2017-12-01', 2, 4, '566.1100000000', '566.1100000000', '2017-12-01', 'Francisco Ulate Azofeifa'),
('2017-12-01', 2, 9, '571.0000000000', '559.0000000000', '2017-12-01', 'Francisco Ulate Azofeifa'),
('2017-12-04', 2, 4, '566.1700000000', '566.1700000000', '2017-12-04', 'Francisco Ulate Azofeifa'),
('2017-12-04', 2, 9, '571.0000000000', '559.0000000000', '2017-12-04', 'Francisco Ulate Azofeifa'),
('2017-12-05', 2, 4, '566.4000000000', '566.4000000000', '2017-12-05', 'Francisco Ulate Azofeifa'),
('2017-12-05', 2, 9, '572.2500000000', '560.2500000000', '2017-12-05', 'Francisco Ulate Azofeifa'),
('2017-12-06', 2, 4, '566.3700000000', '566.3700000000', '2017-12-06', 'Francisco Ulate Azofeifa'),
('2017-12-06', 2, 9, '572.2500000000', '560.2500000000', '2017-12-06', 'Francisco Ulate Azofeifa'),
('2017-12-07', 2, 4, '566.1900000000', '566.1900000000', '2017-12-07', 'Francisco Ulate Azofeifa'),
('2017-12-07', 2, 9, '572.7500000000', '559.7500000000', '2017-12-07', 'Francisco Ulate Azofeifa'),
('2017-12-08', 2, 4, '566.1200000000', '566.1200000000', '2017-12-08', 'Francisco Ulate Azofeifa'),
('2017-12-08', 2, 9, '572.7500000000', '559.7500000000', '2017-12-08', 'Francisco Ulate Azofeifa'),
('2017-12-11', 2, 4, '565.9000000000', '565.9000000000', '2017-12-11', 'Francisco Ulate Azofeifa'),
('2017-12-11', 2, 9, '572.7500000000', '559.7500000000', '2017-12-11', 'Francisco Ulate Azofeifa'),
('2017-12-12', 2, 4, '566.0100000000', '566.0100000000', '2017-12-12', 'Francisco Ulate Azofeifa'),
('2017-12-12', 2, 9, '572.7500000000', '559.7500000000', '2017-12-12', 'Francisco Ulate Azofeifa'),
('2017-12-13', 2, 4, '566.2300000000', '566.2300000000', '2017-12-13', 'Francisco Ulate Azofeifa'),
('2017-12-13', 2, 9, '572.7500000000', '559.7500000000', '2017-12-13', 'Francisco Ulate Azofeifa'),
('2017-12-14', 2, 4, '566.2800000000', '566.2800000000', '2017-12-14', 'Francisco Ulate Azofeifa'),
('2017-12-14', 2, 9, '572.7500000000', '559.7500000000', '2017-12-14', 'Francisco Ulate Azofeifa'),
('2017-12-15', 2, 4, '566.2400000000', '566.2400000000', '2017-12-15', 'Francisco Ulate Azofeifa'),
('2017-12-15', 2, 9, '572.7500000000', '559.7500000000', '2017-12-15', 'Francisco Ulate Azofeifa'),
('2017-12-18', 2, 4, '566.0100000000', '566.0100000000', '2017-12-18', 'Francisco Ulate Azofeifa'),
('2017-12-18', 2, 9, '572.7500000000', '559.7500000000', '2017-12-18', 'Francisco Ulate Azofeifa'),
('2017-12-19', 2, 4, '566.0000000000', '566.0000000000', '2017-12-19', 'Francisco Ulate Azofeifa'),
('2017-12-19', 2, 9, '572.7500000000', '559.7500000000', '2017-12-19', 'Francisco Ulate Azofeifa'),
('2017-12-20', 2, 4, '566.2700000000', '566.2700000000', '2017-12-20', 'Francisco Ulate Azofeifa'),
('2017-12-20', 2, 9, '572.7500000000', '559.7500000000', '2017-12-20', 'Francisco Ulate Azofeifa'),
('2017-12-21', 2, 4, '568.0300000000', '568.0300000000', '2017-12-21', 'Francisco Ulate Azofeifa'),
('2017-12-21', 2, 9, '572.7500000000', '559.7500000000', '2017-12-21', 'Francisco Ulate Azofeifa'),
('2017-12-22', 2, 4, '568.9200000000', '568.9200000000', '2017-12-22', 'Francisco Ulate Azofeifa'),
('2017-12-22', 2, 9, '575.5000000000', '562.5000000000', '2017-12-22', 'Francisco Ulate Azofeifa'),
('2018-01-02', 2, 4, '570.2000000000', '570.2000000000', '2018-01-02', 'Francisco Ulate Azofeifa'),
('2018-01-02', 2, 9, '575.5000000000', '562.5000000000', '2018-01-02', 'Francisco Ulate Azofeifa'),
('2018-01-03', 2, 4, '569.8000000000', '569.8000000000', '2018-01-03', 'Francisco Ulate Azofeifa'),
('2018-01-03', 2, 9, '575.5000000000', '562.5000000000', '2018-01-03', 'Francisco Ulate Azofeifa'),
('2018-01-04', 2, 4, '570.0000000000', '570.0000000000', '2018-01-04', 'Francisco Ulate Azofeifa'),
('2018-01-04', 2, 9, '575.5000000000', '562.5000000000', '2018-01-04', 'Francisco Ulate Azofeifa'),
('2018-01-05', 2, 4, '570.6400000000', '570.6400000000', '2018-01-05', 'Francisco Ulate Azofeifa'),
('2018-01-05', 2, 9, '575.5000000000', '562.5000000000', '2018-01-05', 'Francisco Ulate Azofeifa'),
('2018-01-08', 2, 4, '570.4600000000', '570.4600000000', '2018-01-08', 'Francisco Ulate Azofeifa'),
('2018-01-08', 2, 9, '575.5000000000', '562.5000000000', '2018-01-08', 'Francisco Ulate Azofeifa'),
('2018-01-09', 2, 4, '570.3900000000', '570.3900000000', '2018-01-09', 'Francisco Ulate Azofeifa'),
('2018-01-09', 2, 9, '575.5000000000', '562.5000000000', '2018-01-09', 'Francisco Ulate Azofeifa'),
('2018-01-10', 2, 4, '570.5000000000', '570.5000000000', '2018-01-10', 'Francisco Ulate Azofeifa'),
('2018-01-10', 2, 9, '575.5000000000', '562.5000000000', '2018-01-10', 'Francisco Ulate Azofeifa'),
('2018-01-11', 2, 4, '570.7800000000', '570.7800000000', '2018-01-11', 'Francisco Ulate Azofeifa'),
('2018-01-11', 2, 9, '575.5000000000', '562.5000000000', '2018-01-11', 'Francisco Ulate Azofeifa'),
('2018-01-12', 2, 4, '570.0000000000', '570.0000000000', '2018-01-12', 'Francisco Ulate Azofeifa'),
('2018-01-12', 2, 9, '575.5000000000', '562.5000000000', '2018-01-12', 'Francisco Ulate Azofeifa'),
('2018-01-15', 2, 4, '569.5800000000', '569.5800000000', '2018-01-15', 'Francisco Ulate Azofeifa'),
('2018-01-15', 2, 9, '575.5000000000', '562.5000000000', '2018-01-15', 'Francisco Ulate Azofeifa'),
('2018-01-16', 2, 4, '568.6700000000', '568.6700000000', '2018-01-16', 'Francisco Ulate Azofeifa'),
('2018-01-16', 2, 9, '575.5000000000', '562.5000000000', '2018-01-16', 'Francisco Ulate Azofeifa'),
('2018-01-17', 2, 4, '568.0700000000', '568.0700000000', '2018-01-17', 'Francisco Ulate Azofeifa'),
('2018-01-17', 2, 9, '575.5000000000', '562.5000000000', '2018-01-17', 'Francisco Ulate Azofeifa'),
('2018-01-18', 2, 4, '568.0800000000', '568.0800000000', '2018-01-18', 'Francisco Ulate Azofeifa'),
('2018-01-18', 2, 9, '575.5000000000', '562.5000000000', '2018-01-18', 'Francisco Ulate Azofeifa'),
('2018-01-19', 2, 4, '568.6700000000', '568.6700000000', '2018-01-19', 'Francisco Ulate Azofeifa'),
('2018-01-19', 2, 9, '575.5000000000', '562.5000000000', '2018-01-19', 'Francisco Ulate Azofeifa'),
('2018-01-22', 2, 4, '568.7600000000', '568.7600000000', '2018-01-22', 'Francisco Ulate Azofeifa'),
('2018-01-22', 2, 9, '575.5000000000', '562.5000000000', '2018-01-22', 'Francisco Ulate Azofeifa'),
('2018-01-23', 2, 4, '569.2100000000', '569.2100000000', '2018-01-23', 'Francisco Ulate Azofeifa'),
('2018-01-23', 2, 9, '575.5000000000', '562.5000000000', '2018-01-23', 'Francisco Ulate Azofeifa'),
('2018-01-24', 2, 4, '569.2700000000', '569.2700000000', '2018-01-24', 'Francisco Ulate Azofeifa'),
('2018-01-24', 2, 9, '575.5000000000', '562.5000000000', '2018-01-24', 'Francisco Ulate Azofeifa'),
('2018-01-25', 2, 4, '569.4300000000', '569.4300000000', '2018-01-25', 'Francisco Ulate Azofeifa'),
('2018-01-25', 2, 9, '575.5000000000', '562.5000000000', '2018-01-25', 'Francisco Ulate Azofeifa'),
('2018-01-26', 2, 4, '569.1400000000', '569.1400000000', '2018-01-26', 'Francisco Ulate Azofeifa'),
('2018-01-26', 2, 9, '575.5000000000', '562.5000000000', '2018-01-26', 'Francisco Ulate Azofeifa'),
('2018-01-29', 2, 4, '569.0400000000', '569.0400000000', '2018-01-29', 'Francisco Ulate Azofeifa'),
('2018-01-29', 2, 9, '575.5000000000', '562.5000000000', '2018-01-29', 'Francisco Ulate Azofeifa'),
('2018-01-30', 2, 4, '569.9100000000', '569.9100000000', '2018-01-30', 'Francisco Ulate Azofeifa'),
('2018-01-30', 2, 9, '575.5000000000', '562.5000000000', '2018-01-30', 'Francisco Ulate Azofeifa'),
('2018-01-31', 2, 4, '570.7000000000', '570.7000000000', '2018-01-31', 'Francisco Ulate Azofeifa'),
('2018-01-31', 2, 9, '575.5000000000', '562.5000000000', '2018-01-31', 'Francisco Ulate Azofeifa'),
('2018-02-01', 2, 4, '571.7700000000', '571.7700000000', '2018-02-01', 'Francisco Ulate Azofeifa'),
('2018-02-01', 2, 9, '576.5000000000', '563.5000000000', '2018-02-01', 'Francisco Ulate Azofeifa'),
('2018-02-02', 2, 4, '571.7300000000', '571.7300000000', '2018-02-02', 'Francisco Ulate Azofeifa'),
('2018-02-02', 2, 9, '576.5000000000', '563.5000000000', '2018-02-02', 'Francisco Ulate Azofeifa'),
('2018-02-05', 2, 4, '572.2600000000', '572.2600000000', '2018-02-05', 'Francisco Ulate Azofeifa'),
('2018-02-05', 2, 9, '576.5000000000', '563.5000000000', '2018-02-05', 'Francisco Ulate Azofeifa'),
('2018-02-06', 2, 4, '573.7400000000', '573.7400000000', '2018-02-06', 'Francisco Ulate Azofeifa'),
('2018-02-06', 2, 9, '578.0000000000', '565.0000000000', '2018-02-06', 'Francisco Ulate Azofeifa'),
('2018-02-07', 2, 4, '574.9700000000', '574.9700000000', '2018-02-07', 'Francisco Ulate Azofeifa'),
('2018-02-07', 2, 9, '578.0000000000', '565.0000000000', '2018-02-07', 'Francisco Ulate Azofeifa'),
('2018-02-08', 2, 4, '575.5400000000', '575.5400000000', '2018-02-08', 'Francisco Ulate Azofeifa'),
('2018-02-08', 2, 9, '582.0000000000', '569.0000000000', '2018-02-08', 'Francisco Ulate Azofeifa'),
('2018-02-09', 2, 4, '574.1200000000', '574.1200000000', '2018-02-09', 'Francisco Ulate Azofeifa'),
('2018-02-09', 2, 9, '580.0000000000', '567.0000000000', '2018-02-09', 'Francisco Ulate Azofeifa'),
('2018-02-12', 2, 4, '572.3200000000', '572.3200000000', '2018-02-12', 'Francisco Ulate Azofeifa'),
('2018-02-12', 2, 9, '579.0000000000', '566.0000000000', '2018-02-12', 'Francisco Ulate Azofeifa'),
('2018-02-13', 2, 4, '570.4100000000', '570.4100000000', '2018-02-13', 'Francisco Ulate Azofeifa'),
('2018-02-13', 2, 9, '577.5000000000', '564.5000000000', '2018-02-13', 'Francisco Ulate Azofeifa'),
('2018-02-14', 2, 4, '569.4300000000', '569.4300000000', '2018-02-14', 'Francisco Ulate Azofeifa'),
('2018-02-14', 2, 9, '577.5000000000', '564.5000000000', '2018-02-14', 'Francisco Ulate Azofeifa'),
('2018-02-15', 2, 4, '569.1300000000', '569.1300000000', '2018-02-19', 'Francisco Ulate Azofeifa'),
('2018-02-15', 2, 9, '577.5000000000', '564.5000000000', '2018-02-19', 'Francisco Ulate Azofeifa'),
('2018-02-16', 2, 4, '569.2500000000', '569.2500000000', '2018-02-19', 'Francisco Ulate Azofeifa'),
('2018-02-16', 2, 9, '577.5000000000', '564.5000000000', '2018-02-19', 'Francisco Ulate Azofeifa'),
('2018-02-19', 2, 4, '569.5200000000', '569.5200000000', '2018-02-19', 'Francisco Ulate Azofeifa'),
('2018-02-19', 2, 9, '577.5000000000', '564.5000000000', '2018-02-19', 'Francisco Ulate Azofeifa'),
('2018-02-20', 2, 4, '569.5600000000', '569.5600000000', '2018-02-20', 'Francisco Ulate Azofeifa'),
('2018-02-20', 2, 9, '577.5000000000', '564.5000000000', '2018-02-20', 'Francisco Ulate Azofeifa'),
('2018-02-21', 2, 4, '569.4800000000', '569.4800000000', '2018-02-21', 'Francisco Ulate Azofeifa'),
('2018-02-21', 2, 9, '577.5000000000', '564.5000000000', '2018-02-21', 'Francisco Ulate Azofeifa'),
('2018-02-22', 2, 4, '570.1900000000', '570.1900000000', '2018-02-22', 'Francisco Ulate Azofeifa'),
('2018-02-22', 2, 9, '577.5000000000', '564.5000000000', '2018-02-22', 'Francisco Ulate Azofeifa'),
('2018-02-23', 2, 4, '569.9100000000', '569.9100000000', '2018-02-23', 'Francisco Ulate Azofeifa'),
('2018-02-23', 2, 9, '577.5000000000', '564.5000000000', '2018-02-23', 'Francisco Ulate Azofeifa'),
('2018-02-26', 2, 4, '569.7200000000', '569.7200000000', '2018-02-26', 'Francisco Ulate Azofeifa'),
('2018-02-26', 2, 9, '577.5000000000', '564.5000000000', '2018-02-26', 'Francisco Ulate Azofeifa'),
('2018-02-27', 2, 4, '569.8800000000', '569.8800000000', '2018-02-27', 'Francisco Ulate Azofeifa'),
('2018-02-27', 2, 9, '577.5000000000', '564.5000000000', '2018-02-27', 'Francisco Ulate Azofeifa'),
('2018-02-28', 2, 4, '570.1200000000', '570.1200000000', '2018-02-28', 'Francisco Ulate Azofeifa'),
('2018-02-28', 2, 9, '577.5000000000', '564.5000000000', '2018-02-28', 'Francisco Ulate Azofeifa'),
('2018-03-01', 2, 4, '569.8300000000', '569.8300000000', '2018-03-01', 'Francisco Ulate Azofeifa'),
('2018-03-01', 2, 9, '577.5000000000', '564.5000000000', '2018-03-01', 'Francisco Ulate Azofeifa'),
('2018-03-02', 2, 4, '569.8500000000', '569.8500000000', '2018-03-02', 'Francisco Ulate Azofeifa'),
('2018-03-02', 2, 9, '576.5000000000', '563.5000000000', '2018-03-02', 'Francisco Ulate Azofeifa'),
('2018-03-05', 2, 4, '569.7000000000', '569.7000000000', '2018-03-05', 'Francisco Ulate Azofeifa'),
('2018-03-05', 2, 9, '576.5000000000', '563.5000000000', '2018-03-05', 'Francisco Ulate Azofeifa'),
('2018-03-06', 2, 4, '569.6200000000', '569.6200000000', '2018-03-06', 'Francisco Ulate Azofeifa'),
('2018-03-06', 2, 9, '576.5000000000', '563.5000000000', '2018-03-06', 'Francisco Ulate Azofeifa'),
('2018-03-07', 2, 4, '569.5000000000', '569.5000000000', '2018-03-07', 'Francisco Ulate Azofeifa'),
('2018-03-07', 2, 9, '576.5000000000', '563.5000000000', '2018-03-07', 'Francisco Ulate Azofeifa'),
('2018-03-08', 2, 4, '569.6500000000', '569.6500000000', '2018-03-08', 'Francisco Ulate Azofeifa'),
('2018-03-08', 2, 9, '576.5000000000', '563.5000000000', '2018-03-08', 'Francisco Ulate Azofeifa'),
('2018-03-09', 2, 4, '569.4400000000', '569.4400000000', '2018-03-09', 'Francisco Ulate Azofeifa'),
('2018-03-09', 2, 9, '576.5000000000', '563.5000000000', '2018-03-09', 'Francisco Ulate Azofeifa'),
('2018-03-12', 2, 4, '569.4400000000', '569.4400000000', '2018-03-12', 'Francisco Ulate Azofeifa'),
('2018-03-12', 2, 9, '575.5000000000', '562.5000000000', '2018-03-12', 'Francisco Ulate Azofeifa'),
('2018-03-13', 2, 4, '569.2300000000', '569.2300000000', '2018-03-13', 'Francisco Ulate Azofeifa'),
('2018-03-13', 2, 9, '575.5000000000', '562.5000000000', '2018-03-13', 'Francisco Ulate Azofeifa'),
('2018-03-14', 2, 4, '568.6800000000', '568.6800000000', '2018-03-14', 'Francisco Ulate Azofeifa'),
('2018-03-14', 2, 9, '575.5000000000', '562.5000000000', '2018-03-14', 'Francisco Ulate Azofeifa'),
('2018-03-15', 2, 4, '567.6600000000', '567.6600000000', '2018-03-15', 'Francisco Ulate Azofeifa'),
('2018-03-15', 2, 9, '573.5000000000', '560.5000000000', '2018-03-15', 'Francisco Ulate Azofeifa'),
('2018-03-16', 2, 4, '565.9100000000', '565.9100000000', '2018-03-16', 'Francisco Ulate Azofeifa'),
('2018-03-16', 2, 9, '572.5000000000', '559.5000000000', '2018-03-16', 'Francisco Ulate Azofeifa'),
('2018-03-19', 2, 4, '565.6900000000', '565.6900000000', '2018-03-19', 'Francisco Ulate Azofeifa'),
('2018-03-19', 2, 9, '572.5000000000', '559.5000000000', '2018-03-19', 'Francisco Ulate Azofeifa'),
('2018-03-20', 2, 4, '565.2200000000', '565.2200000000', '2018-03-20', 'Francisco Ulate Azofeifa'),
('2018-03-20', 2, 9, '572.5000000000', '559.5000000000', '2018-03-20', 'Francisco Ulate Azofeifa'),
('2018-03-21', 2, 4, '565.1100000000', '565.1100000000', '2018-03-21', 'Francisco Ulate Azofeifa'),
('2018-03-21', 2, 9, '572.5000000000', '559.5000000000', '2018-03-21', 'Francisco Ulate Azofeifa'),
('2018-03-22', 2, 4, '565.0600000000', '565.0600000000', '2018-03-22', 'Francisco Ulate Azofeifa'),
('2018-03-22', 2, 9, '572.5000000000', '559.5000000000', '2018-03-22', 'Francisco Ulate Azofeifa'),
('2018-03-23', 2, 4, '564.8300000000', '564.8300000000', '2018-03-23', 'Francisco Ulate Azofeifa'),
('2018-03-23', 2, 9, '571.5000000000', '558.5000000000', '2018-03-23', 'Francisco Ulate Azofeifa'),
('2018-03-26', 2, 4, '565.3400000000', '565.3400000000', '2018-03-26', 'Francisco Ulate Azofeifa'),
('2018-03-26', 2, 9, '571.5000000000', '558.5000000000', '2018-03-26', 'Francisco Ulate Azofeifa'),
('2018-03-27', 2, 4, '565.8500000000', '565.8500000000', '2018-03-27', 'Francisco Ulate Azofeifa'),
('2018-03-27', 2, 9, '572.5000000000', '559.5000000000', '2018-03-27', 'Francisco Ulate Azofeifa'),
('2018-04-02', 2, 4, '566.3900000000', '566.3900000000', '2018-04-02', 'Francisco Ulate Azofeifa'),
('2018-04-02', 2, 9, '572.5000000000', '559.5000000000', '2018-04-02', 'Francisco Ulate Azofeifa'),
('2018-04-03', 2, 4, '565.8600000000', '565.8600000000', '2018-04-03', 'Francisco Ulate Azofeifa'),
('2018-04-03', 2, 9, '572.5000000000', '559.5000000000', '2018-04-03', 'Francisco Ulate Azofeifa'),
('2018-04-04', 2, 4, '566.4700000000', '566.4700000000', '2018-04-04', 'Francisco Ulate Azofeifa'),
('2018-04-04', 2, 9, '572.5000000000', '559.5000000000', '2018-04-04', 'Francisco Ulate Azofeifa'),
('2018-04-05', 2, 4, '567.1800000000', '567.1800000000', '2018-04-05', 'Francisco Ulate Azofeifa'),
('2018-04-05', 2, 9, '572.5000000000', '559.5000000000', '2018-04-05', 'Francisco Ulate Azofeifa'),
('2018-04-06', 2, 4, '568.1500000000', '568.1500000000', '2018-04-06', 'Francisco Ulate Azofeifa'),
('2018-04-06', 2, 9, '574.0000000000', '561.0000000000', '2018-04-06', 'Francisco Ulate Azofeifa'),
('2018-04-09', 2, 4, '567.8200000000', '567.8200000000', '2018-04-09', 'Francisco Ulate Azofeifa'),
('2018-04-09', 2, 9, '573.0000000000', '560.0000000000', '2018-04-09', 'Francisco Ulate Azofeifa'),
('2018-04-10', 2, 4, '566.5300000000', '566.5300000000', '2018-04-10', 'Francisco Ulate Azofeifa'),
('2018-04-10', 2, 9, '572.0000000000', '559.0000000000', '2018-04-10', 'Francisco Ulate Azofeifa'),
('2018-04-12', 2, 4, '565.9700000000', '565.9700000000', '2018-04-12', 'Francisco Ulate Azofeifa'),
('2018-04-12', 2, 9, '572.0000000000', '559.0000000000', '2018-04-12', 'Francisco Ulate Azofeifa'),
('2018-04-13', 2, 4, '565.2500000000', '565.2500000000', '2018-04-13', 'Francisco Ulate Azofeifa'),
('2018-04-13', 2, 9, '572.0000000000', '559.0000000000', '2018-04-13', 'Francisco Ulate Azofeifa'),
('2018-04-16', 2, 4, '564.9800000000', '564.9800000000', '2018-04-16', 'Francisco Ulate Azofeifa'),
('2018-04-16', 2, 9, '571.0000000000', '558.0000000000', '2018-04-16', 'Francisco Ulate Azofeifa'),
('2018-04-17', 2, 4, '564.5000000000', '564.5000000000', '2018-04-17', 'Francisco Ulate Azofeifa'),
('2018-04-17', 2, 9, '571.0000000000', '558.0000000000', '2018-04-17', 'Francisco Ulate Azofeifa'),
('2018-04-18', 2, 4, '564.4400000000', '564.4400000000', '2018-04-18', 'Francisco Ulate Azofeifa'),
('2018-04-18', 2, 9, '571.0000000000', '558.0000000000', '2018-04-18', 'Francisco Ulate Azofeifa'),
('2018-04-19', 2, 4, '564.6800000000', '564.6800000000', '2018-04-19', 'Francisco Ulate Azofeifa'),
('2018-04-19', 2, 9, '571.0000000000', '558.0000000000', '2018-04-19', 'Francisco Ulate Azofeifa'),
('2018-04-20', 2, 4, '564.7600000000', '564.7600000000', '2018-04-20', 'Francisco Ulate Azofeifa'),
('2018-04-20', 2, 9, '571.0000000000', '558.0000000000', '2018-04-20', 'Francisco Ulate Azofeifa'),
('2018-04-23', 2, 4, '565.4000000000', '565.4000000000', '2018-04-23', 'Francisco Ulate Azofeifa'),
('2018-04-23', 2, 9, '571.0000000000', '558.0000000000', '2018-04-23', 'Francisco Ulate Azofeifa'),
('2018-04-24', 2, 4, '565.0900000000', '565.0900000000', '2018-04-24', 'Francisco Ulate Azofeifa'),
('2018-04-24', 2, 9, '571.0000000000', '558.0000000000', '2018-04-24', 'Francisco Ulate Azofeifa'),
('2018-04-25', 2, 4, '564.9600000000', '564.9600000000', '2018-04-25', 'Francisco Ulate Azofeifa'),
('2018-04-25', 2, 9, '571.0000000000', '558.0000000000', '2018-04-25', 'Francisco Ulate Azofeifa'),
('2018-04-26', 2, 4, '565.2100000000', '565.2100000000', '2018-04-26', 'Francisco Ulate Azofeifa'),
('2018-04-26', 2, 9, '571.0000000000', '558.0000000000', '2018-04-26', 'Francisco Ulate Azofeifa'),
('2018-04-27', 2, 4, '565.2700000000', '565.2700000000', '2018-04-27', 'Francisco Ulate Azofeifa'),
('2018-04-27', 2, 9, '571.0000000000', '558.0000000000', '2018-04-27', 'Francisco Ulate Azofeifa'),
('2018-04-30', 2, 4, '567.0000000000', '567.0000000000', '2018-04-30', 'Francisco Ulate Azofeifa'),
('2018-04-30', 2, 9, '571.0000000000', '558.0000000000', '2018-04-30', 'Francisco Ulate Azofeifa'),
('2018-05-02', 2, 4, '566.1700000000', '566.1700000000', '2018-05-02', 'Francisco Ulate Azofeifa'),
('2018-05-02', 2, 9, '571.0000000000', '558.0000000000', '2018-05-02', 'Francisco Ulate Azofeifa'),
('2018-05-03', 2, 4, '565.9300000000', '565.9300000000', '2018-05-03', 'Francisco Ulate Azofeifa'),
('2018-05-03', 2, 9, '571.0000000000', '558.0000000000', '2018-05-03', 'Francisco Ulate Azofeifa'),
('2018-05-04', 2, 4, '566.6200000000', '566.6200000000', '2018-05-04', 'Francisco Ulate Azofeifa'),
('2018-05-04', 2, 9, '571.0000000000', '558.0000000000', '2018-05-04', 'Francisco Ulate Azofeifa'),
('2018-05-07', 2, 4, '567.3700000000', '567.3700000000', '2018-05-07', 'Francisco Ulate Azofeifa'),
('2018-05-07', 2, 9, '571.0000000000', '558.0000000000', '2018-05-07', 'Francisco Ulate Azofeifa'),
('2018-05-08', 2, 4, '567.0200000000', '567.0200000000', '2018-05-08', 'Francisco Ulate Azofeifa'),
('2018-05-08', 2, 9, '571.0000000000', '558.0000000000', '2018-05-08', 'Francisco Ulate Azofeifa'),
('2018-05-09', 2, 4, '567.0200000000', '567.0200000000', '2018-05-09', 'Francisco Ulate Azofeifa'),
('2018-05-09', 2, 9, '571.0000000000', '558.0000000000', '2018-05-09', 'Francisco Ulate Azofeifa'),
('2018-05-10', 2, 4, '567.0100000000', '567.0100000000', '2018-05-10', 'Francisco Ulate Azofeifa'),
('2018-05-10', 2, 9, '571.0000000000', '558.0000000000', '2018-05-10', 'Francisco Ulate Azofeifa'),
('2018-05-11', 2, 4, '567.0100000000', '567.0100000000', '2018-05-11', 'Francisco Ulate Azofeifa'),
('2018-05-11', 2, 9, '571.0000000000', '558.0000000000', '2018-05-11', 'Francisco Ulate Azofeifa'),
('2018-05-14', 2, 4, '566.9800000000', '566.9800000000', '2018-05-14', 'Francisco Ulate Azofeifa'),
('2018-05-14', 2, 9, '571.0000000000', '558.0000000000', '2018-05-14', 'Francisco Ulate Azofeifa'),
('2018-05-15', 2, 4, '565.9600000000', '565.9600000000', '2018-05-15', 'Francisco Ulate Azofeifa'),
('2018-05-15', 2, 9, '571.0000000000', '558.0000000000', '2018-05-15', 'Francisco Ulate Azofeifa'),
('2018-05-16', 2, 4, '565.5000000000', '565.5000000000', '2018-05-16', 'Francisco Ulate Azofeifa'),
('2018-05-16', 2, 9, '571.0000000000', '558.0000000000', '2018-05-16', 'Francisco Ulate Azofeifa'),
('2018-05-17', 2, 4, '564.9100000000', '564.9100000000', '2018-05-17', 'Francisco Ulate Azofeifa'),
('2018-05-17', 2, 9, '571.0000000000', '558.0000000000', '2018-05-17', 'Francisco Ulate Azofeifa'),
('2018-05-18', 2, 4, '564.7400000000', '564.7400000000', '2018-05-18', 'Francisco Ulate Azofeifa'),
('2018-05-18', 2, 9, '571.0000000000', '558.0000000000', '2018-05-18', 'Francisco Ulate Azofeifa'),
('2018-05-21', 2, 4, '564.4400000000', '564.4400000000', '2018-05-21', 'Francisco Ulate Azofeifa'),
('2018-05-21', 2, 9, '571.0000000000', '558.0000000000', '2018-05-21', 'Francisco Ulate Azofeifa'),
('2018-05-22', 2, 4, '563.9800000000', '563.9800000000', '2018-05-22', 'Francisco Ulate Azofeifa'),
('2018-05-22', 2, 9, '571.0000000000', '558.0000000000', '2018-05-22', 'Francisco Ulate Azofeifa'),
('2018-05-23', 2, 4, '564.4100000000', '564.4100000000', '2018-05-23', 'Francisco Ulate Azofeifa'),
('2018-05-23', 2, 9, '571.0000000000', '558.0000000000', '2018-05-23', 'Francisco Ulate Azofeifa'),
('2018-05-24', 2, 4, '565.3800000000', '565.3800000000', '2018-05-24', 'Francisco Ulate Azofeifa'),
('2018-05-24', 2, 9, '571.0000000000', '558.0000000000', '2018-05-24', 'Francisco Ulate Azofeifa'),
('2018-05-25', 2, 4, '565.9000000000', '565.9000000000', '2018-05-25', 'Francisco Ulate Azofeifa'),
('2018-05-25', 2, 9, '571.0000000000', '558.0000000000', '2018-05-25', 'Francisco Ulate Azofeifa'),
('2018-05-28', 2, 4, '565.3500000000', '565.3500000000', '2018-05-28', 'Francisco Ulate Azofeifa'),
('2018-05-28', 2, 9, '571.0000000000', '558.0000000000', '2018-05-28', 'Francisco Ulate Azofeifa'),
('2018-05-29', 2, 4, '566.6600000000', '566.6600000000', '2018-05-29', 'Francisco Ulate Azofeifa'),
('2018-05-29', 2, 9, '572.0000000000', '559.0000000000', '2018-05-29', 'Francisco Ulate Azofeifa'),
('2018-05-30', 2, 4, '566.5800000000', '566.5800000000', '2018-05-30', 'Francisco Ulate Azofeifa'),
('2018-05-30', 2, 9, '572.0000000000', '559.0000000000', '2018-05-30', 'Francisco Ulate Azofeifa'),
('2018-05-31', 2, 4, '567.2300000000', '567.2300000000', '2018-05-31', 'Francisco Ulate Azofeifa'),
('2018-05-31', 2, 9, '572.0000000000', '559.0000000000', '2018-05-31', 'Francisco Ulate Azofeifa'),
('2018-06-01', 2, 4, '568.6700000000', '568.6700000000', '2018-06-01', 'Francisco Ulate Azofeifa'),
('2018-06-01', 2, 9, '574.0000000000', '561.0000000000', '2018-06-01', 'Francisco Ulate Azofeifa'),
('2018-06-04', 2, 4, '567.5000000000', '567.5000000000', '2018-06-04', 'Francisco Ulate Azofeifa'),
('2018-06-04', 2, 9, '573.0000000000', '560.0000000000', '2018-06-04', 'Francisco Ulate Azofeifa'),
('2018-06-05', 2, 4, '567.7500000000', '567.7500000000', '2018-06-05', 'Francisco Ulate Azofeifa'),
('2018-06-05', 2, 9, '573.0000000000', '560.0000000000', '2018-06-05', 'Francisco Ulate Azofeifa'),
('2018-06-06', 2, 4, '568.0800000000', '568.0800000000', '2018-06-06', 'Francisco Ulate Azofeifa'),
('2018-06-06', 2, 9, '574.2500000000', '561.2500000000', '2018-06-06', 'Francisco Ulate Azofeifa'),
('2018-06-07', 2, 4, '568.4100000000', '568.4100000000', '2018-06-07', 'Francisco Ulate Azofeifa'),
('2018-06-07', 2, 9, '574.2500000000', '561.2500000000', '2018-06-07', 'Francisco Ulate Azofeifa'),
('2018-06-08', 2, 4, '568.5800000000', '568.5800000000', '2018-06-08', 'Francisco Ulate Azofeifa'),
('2018-06-08', 2, 9, '574.2500000000', '561.2500000000', '2018-06-08', 'Francisco Ulate Azofeifa'),
('2018-06-11', 2, 4, '568.7400000000', '568.7400000000', '2018-06-11', 'Francisco Ulate Azofeifa'),
('2018-06-11', 2, 9, '574.2500000000', '561.2500000000', '2018-06-11', 'Francisco Ulate Azofeifa'),
('2018-06-12', 2, 4, '568.7000000000', '568.7000000000', '2018-06-12', 'Francisco Ulate Azofeifa');
INSERT INTO `sis_tipo_cambio_monedas` (`fec_tipo_cambio`, `cod_moneda`, `cod_fuente`, `num_valor`, `num_valor_compra`, `fec_modificacion`, `cod_usuario_modificacion`) VALUES
('2018-06-12', 2, 9, '574.2500000000', '561.2500000000', '2018-06-12', 'Francisco Ulate Azofeifa'),
('2018-06-13', 2, 4, '567.9600000000', '567.9600000000', '2018-06-13', 'Francisco Ulate Azofeifa'),
('2018-06-13', 2, 9, '574.2500000000', '561.2500000000', '2018-06-13', 'Francisco Ulate Azofeifa'),
('2018-06-14', 2, 4, '567.7900000000', '567.7900000000', '2018-06-14', 'Francisco Ulate Azofeifa'),
('2018-06-14', 2, 9, '574.2500000000', '561.2500000000', '2018-06-14', 'Francisco Ulate Azofeifa'),
('2018-06-15', 2, 4, '567.5400000000', '567.5400000000', '2018-06-15', 'Francisco Ulate Azofeifa'),
('2018-06-15', 2, 9, '574.2500000000', '561.2500000000', '2018-06-15', 'Francisco Ulate Azofeifa'),
('2018-06-16', 2, 4, '567.7100000000', '567.7100000000', '2018-06-17', 'Francisco Ulate Azofeifa'),
('2018-06-16', 2, 9, '574.2500000000', '561.2500000000', '2018-06-17', 'Francisco Ulate Azofeifa'),
('2018-06-17', 2, 4, '567.7100000000', '567.7100000000', '2018-06-17', 'Francisco Ulate Azofeifa'),
('2018-06-17', 2, 9, '574.2500000000', '561.2500000000', '2018-06-17', 'Francisco Ulate Azofeifa'),
('2018-06-18', 2, 4, '567.7100000000', '567.7100000000', '2018-06-18', 'Francisco Ulate Azofeifa'),
('2018-06-18', 2, 9, '574.2500000000', '561.2500000000', '2018-06-18', 'Francisco Ulate Azofeifa'),
('2018-06-19', 2, 4, '567.5800000000', '567.5800000000', '2018-06-19', 'Francisco Ulate Azofeifa'),
('2018-06-19', 2, 9, '574.2500000000', '561.2500000000', '2018-06-19', 'Francisco Ulate Azofeifa'),
('2018-06-20', 2, 4, '567.7000000000', '567.7000000000', '2018-06-20', 'Francisco Ulate Azofeifa'),
('2018-06-20', 2, 9, '574.2500000000', '561.2500000000', '2018-06-20', 'Francisco Ulate Azofeifa'),
('2018-06-21', 2, 4, '567.9200000000', '567.9200000000', '2018-06-21', 'Francisco Ulate Azofeifa'),
('2018-06-21', 2, 9, '574.2500000000', '561.2500000000', '2018-06-21', 'Francisco Ulate Azofeifa'),
('2018-06-22', 2, 4, '567.8100000000', '567.8100000000', '2018-06-22', 'Francisco Ulate Azofeifa'),
('2018-06-22', 2, 9, '574.2500000000', '561.2500000000', '2018-06-22', 'Francisco Ulate Azofeifa'),
('2018-06-23', 2, 4, '568.2600000000', '568.2600000000', '2018-06-25', 'Francisco Ulate Azofeifa'),
('2018-06-23', 2, 9, '574.2500000000', '561.2500000000', '2018-06-25', 'Francisco Ulate Azofeifa'),
('2018-06-24', 2, 4, '568.2600000000', '568.2600000000', '2018-06-25', 'Francisco Ulate Azofeifa'),
('2018-06-24', 2, 9, '574.2500000000', '561.2500000000', '2018-06-25', 'Francisco Ulate Azofeifa'),
('2018-06-25', 2, 4, '568.2600000000', '568.2600000000', '2018-06-25', 'Francisco Ulate Azofeifa'),
('2018-06-25', 2, 9, '574.2500000000', '561.2500000000', '2018-06-25', 'Francisco Ulate Azofeifa'),
('2018-06-26', 2, 4, '568.5500000000', '568.5500000000', '2018-06-26', 'Francisco Ulate Azofeifa'),
('2018-06-26', 2, 9, '574.2500000000', '561.2500000000', '2018-06-26', 'Francisco Ulate Azofeifa'),
('2018-06-27', 2, 4, '568.3400000000', '568.3400000000', '2018-06-27', 'Francisco Ulate Azofeifa'),
('2018-06-27', 2, 9, '574.2500000000', '561.2500000000', '2018-06-27', 'Francisco Ulate Azofeifa'),
('2018-06-28', 2, 4, '567.6300000000', '567.6300000000', '2018-06-28', 'Francisco Ulate Azofeifa'),
('2018-06-28', 2, 9, '574.2500000000', '561.2500000000', '2018-06-28', 'Francisco Ulate Azofeifa'),
('2018-06-29', 2, 4, '567.5600000000', '567.5600000000', '2018-06-29', 'Francisco Ulate Azofeifa'),
('2018-06-29', 2, 9, '574.2500000000', '561.2500000000', '2018-06-29', 'Francisco Ulate Azofeifa'),
('2018-06-30', 2, 4, '567.4700000000', '567.4700000000', '2018-06-29', 'Francisco Ulate Azofeifa'),
('2018-06-30', 2, 9, '574.2500000000', '561.2500000000', '2018-06-29', 'Francisco Ulate Azofeifa'),
('2018-07-01', 2, 4, '567.4700000000', '567.4700000000', '2018-06-29', 'Francisco Ulate Azofeifa'),
('2018-07-01', 2, 9, '574.2500000000', '561.2500000000', '2018-06-29', 'Francisco Ulate Azofeifa'),
('2018-07-02', 2, 4, '567.4700000000', '567.4700000000', '2018-07-02', 'Francisco Ulate Azofeifa'),
('2018-07-02', 2, 9, '574.2500000000', '561.2500000000', '2018-07-02', 'Francisco Ulate Azofeifa'),
('2018-07-03', 2, 4, '567.5800000000', '567.5800000000', '2018-07-03', 'Francisco Ulate Azofeifa'),
('2018-07-03', 2, 9, '574.2500000000', '561.2500000000', '2018-07-03', 'Francisco Ulate Azofeifa'),
('2018-07-04', 2, 4, '567.5900000000', '567.5900000000', '2018-07-04', 'Francisco Ulate Azofeifa'),
('2018-07-04', 2, 9, '574.2500000000', '561.2500000000', '2018-07-04', 'Francisco Ulate Azofeifa'),
('2018-07-05', 2, 4, '567.9300000000', '567.9300000000', '2018-07-05', 'Jose Rivas'),
('2018-07-05', 2, 9, '574.2500000000', '561.2500000000', '2018-07-05', 'Jose Rivas'),
('2018-07-06', 2, 4, '567.9300000000', '567.9300000000', '2018-07-06', 'Jose Rivas'),
('2018-07-06', 2, 9, '574.2500000000', '561.2500000000', '2018-07-06', 'Jose Rivas'),
('2018-07-07', 2, 4, '568.0500000000', '568.0500000000', '2018-07-09', 'Francisco Ulate Azofeifa'),
('2018-07-07', 2, 9, '574.2500000000', '561.2500000000', '2018-07-09', 'Francisco Ulate Azofeifa'),
('2018-07-08', 2, 4, '568.0500000000', '568.0500000000', '2018-07-09', 'Francisco Ulate Azofeifa'),
('2018-07-08', 2, 9, '574.2500000000', '561.2500000000', '2018-07-09', 'Francisco Ulate Azofeifa'),
('2018-07-09', 2, 4, '568.2000000000', '568.2000000000', '2018-07-09', 'Jose Rivas'),
('2018-07-09', 2, 9, '574.2500000000', '561.2500000000', '2018-07-09', 'Jose Rivas'),
('2018-07-10', 2, 4, '567.8100000000', '567.8100000000', '2018-07-10', 'Francisco Ulate Azofeifa'),
('2018-07-10', 2, 9, '574.2500000000', '561.2500000000', '2018-07-10', 'Francisco Ulate Azofeifa'),
('2018-07-11', 2, 4, '567.7200000000', '567.7200000000', '2018-07-11', 'Francisco Ulate Azofeifa'),
('2018-07-11', 2, 9, '574.2500000000', '561.2500000000', '2018-07-11', 'Francisco Ulate Azofeifa'),
('2018-07-12', 2, 4, '567.7900000000', '567.7900000000', '2018-07-12', 'Francisco Ulate Azofeifa'),
('2018-07-12', 2, 9, '574.2500000000', '561.2500000000', '2018-07-12', 'Francisco Ulate Azofeifa'),
('2018-07-13', 2, 4, '567.1300000000', '567.1300000000', '2018-07-13', 'Francisco Ulate Azofeifa'),
('2018-07-13', 2, 9, '574.2500000000', '561.2500000000', '2018-07-13', 'Francisco Ulate Azofeifa'),
('2018-07-14', 2, 4, '566.9800000000', '566.9800000000', '2018-07-16', 'Francisco Ulate Azofeifa'),
('2018-07-14', 2, 9, '574.2500000000', '561.2500000000', '2018-07-16', 'Francisco Ulate Azofeifa'),
('2018-07-15', 2, 4, '566.9800000000', '566.9800000000', '2018-07-16', 'Francisco Ulate Azofeifa'),
('2018-07-15', 2, 9, '574.2500000000', '561.2500000000', '2018-07-16', 'Francisco Ulate Azofeifa'),
('2018-07-16', 2, 4, '566.9800000000', '566.9800000000', '2018-07-16', 'Francisco Ulate Azofeifa'),
('2018-07-16', 2, 9, '574.2500000000', '561.2500000000', '2018-07-16', 'Francisco Ulate Azofeifa'),
('2018-07-17', 2, 4, '567.1900000000', '567.1900000000', '2018-07-17', 'Francisco Ulate Azofeifa'),
('2018-07-17', 2, 9, '574.2500000000', '561.2500000000', '2018-07-17', 'Francisco Ulate Azofeifa'),
('2018-07-18', 2, 4, '567.6200000000', '567.6200000000', '2018-07-18', 'Francisco Ulate Azofeifa'),
('2018-07-18', 2, 9, '574.2500000000', '561.2500000000', '2018-07-18', 'Francisco Ulate Azofeifa'),
('2018-07-19', 2, 4, '567.9000000000', '567.9000000000', '2018-07-19', 'Francisco Ulate Azofeifa'),
('2018-07-19', 2, 9, '574.2500000000', '561.2500000000', '2018-07-19', 'Francisco Ulate Azofeifa'),
('2018-07-20', 2, 4, '568.0400000000', '568.0400000000', '2018-07-20', 'Francisco Ulate Azofeifa'),
('2018-07-20', 2, 9, '574.2500000000', '561.2500000000', '2018-07-20', 'Francisco Ulate Azofeifa'),
('2018-07-21', 2, 4, '568.3200000000', '568.3200000000', '2018-07-23', 'Francisco Ulate Azofeifa'),
('2018-07-21', 2, 9, '574.2500000000', '561.2500000000', '2018-07-23', 'Francisco Ulate Azofeifa'),
('2018-07-22', 2, 4, '568.3200000000', '568.3200000000', '2018-07-23', 'Francisco Ulate Azofeifa'),
('2018-07-22', 2, 9, '574.2500000000', '561.2500000000', '2018-07-23', 'Francisco Ulate Azofeifa'),
('2018-07-23', 2, 4, '568.3200000000', '568.3200000000', '2018-07-23', 'Francisco Ulate Azofeifa'),
('2018-07-23', 2, 9, '574.2500000000', '561.2500000000', '2018-07-23', 'Francisco Ulate Azofeifa'),
('2018-07-29', 2, 9, '574.2500000000', '561.2500000000', '2018-07-09', 'Francisco Ulate Azofeifa');

-- --------------------------------------------------------

--
-- Table structure for table `sis_usuarios`
--

CREATE TABLE `sis_usuarios` (
  `cod_usuario` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `cod_clave` varchar(150) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `cod_token` varchar(150) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'Almacena el token de sesion web ',
  `fec_hora_fin_sesion` datetime DEFAULT NULL COMMENT 'Fecha y hora de vencimiento de sesion web del usuario ',
  `fec_vencimiento` date NOT NULL,
  `des_nombre` varchar(50) CHARACTER SET utf16 NOT NULL,
  `des_apellido1` varchar(50) CHARACTER SET utf16 DEFAULT NULL,
  `des_apellido2` varchar(50) CHARACTER SET utf16 DEFAULT NULL,
  `num_identificacion` varchar(50) CHARACTER SET utf16 NOT NULL,
  `cod_perfil` tinyint(5) NOT NULL,
  `ind_estado` varchar(1) CHARACTER SET utf16 NOT NULL,
  `cod_compania` varchar(50) COLLATE utf16_unicode_ci NOT NULL COMMENT 'Cedula de la compañia a la pertenece el cliente',
  `des_compania` varchar(255) CHARACTER SET utf16 DEFAULT NULL,
  `des_foto` varbinary(1500) DEFAULT NULL,
  `des_email` varchar(255) CHARACTER SET utf16 NOT NULL,
  `num_telefono` varchar(50) CHARACTER SET utf16 DEFAULT NULL,
  `des_link_red_social` varchar(255) CHARACTER SET utf16 DEFAULT NULL,
  `ind_alertas_nuevos` char(1) CHARACTER SET utf16 NOT NULL DEFAULT 'N' COMMENT 'Esta campo almacena una S cuando el usuario activó las alertas sobre nuevos negocios en pizarra.',
  `ind_alertas_cambios` char(1) CHARACTER SET utf16 NOT NULL DEFAULT 'N' COMMENT 'Esta campo almacena una S cuando el usuario activó las alertas sobre cambios en posiciones de negocios en los que participa, ya sea inversionista (comprador) o cededor (vendedor) de facturas y/o contratos.',
  `ind_alertas_sms_cambios` char(1) CHARACTER SET utf16 NOT NULL DEFAULT 'S' COMMENT 'Indicador que activa los SMS (S=Activado) ',
  `ind_cierre_bloqueo_operaciones` char(1) CHARACTER SET utf16 NOT NULL DEFAULT 'N' COMMENT 'Esta campo almacena una S cuando el usuario activó el bloqueo de operaciones durante el cierre diario de factoring',
  `mon_minimo_filtro_facial` decimal(20,2) NOT NULL DEFAULT '0.00' COMMENT 'Monto minimo del filtro para mostrar operaciones factoring',
  `num_maximo_filtro_plazo` int(4) NOT NULL DEFAULT '365' COMMENT 'Cantidad maxima del filtro PLAZO para mostrar operaciones factoring',
  `ind_filtro_sector` int(1) NOT NULL DEFAULT '0' COMMENT 'Valos igual a 3 muestra operaciones de pagadores en sector publico y privado. Valor igual a 1 solo sector publico, y valor igual a 2 solo sector privado',
  `ind_filtro_moneda` int(1) NOT NULL DEFAULT '0',
  `ind_filtro_propias` char(1) CHARACTER SET utf16 NOT NULL DEFAULT 'N' COMMENT 'Filtra a los vendedores de facturas, las operaciones propias o todas.',
  `ind_filtro_tipoNegocio` int(1) NOT NULL DEFAULT '0',
  `fec_creacion` date NOT NULL,
  `cod_usuario_creacion` varchar(50) CHARACTER SET utf16 NOT NULL,
  `num_cedula` varchar(50) CHARACTER SET utf16 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci COMMENT='Tabla que almacena los usuarios del sistema';

--
-- Dumping data for table `sis_usuarios`
--

INSERT INTO `sis_usuarios` (`cod_usuario`, `cod_clave`, `cod_token`, `fec_hora_fin_sesion`, `fec_vencimiento`, `des_nombre`, `des_apellido1`, `des_apellido2`, `num_identificacion`, `cod_perfil`, `ind_estado`, `cod_compania`, `des_compania`, `des_foto`, `des_email`, `num_telefono`, `des_link_red_social`, `ind_alertas_nuevos`, `ind_alertas_cambios`, `ind_alertas_sms_cambios`, `ind_cierre_bloqueo_operaciones`, `mon_minimo_filtro_facial`, `num_maximo_filtro_plazo`, `ind_filtro_sector`, `ind_filtro_moneda`, `ind_filtro_propias`, `ind_filtro_tipoNegocio`, `fec_creacion`, `cod_usuario_creacion`, `num_cedula`) VALUES
('aalfaro ', 'TMP70720', '', NULL, '2018-03-20', 'Adrian', 'Alfaro ', 'Palacios', '1890808', 1, 'P', '3101681623', 'Aap Negocios en la Nube S.A', NULL, 'gguillen@masterzon.com', '70116878', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-20', 'WEB', NULL),
('aaraya', 'TMP41929', '', NULL, '2018-03-29', 'Arturo ', 'Araya', 'Araya', '109570178', 1, 'P', '3101121532', 'Centro ferretero industrial Avila S.A.', NULL, 'gguillen@masterzon.com', '2233-0153', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-29', 'WEB', NULL),
('aaraya651', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-06-14 16:48:38', '2019-04-04', 'Alexander', 'Araya', 'Mena', '109070896', 4, 'A', '3101316814', 'GRUPO OROSI S.A', NULL, 'gguillen@masterzon.com', '70708600', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('acampos ', '$2y$10$AS0cf6OQ4RSi3x1Nk5PYPOwhZ.OD7q1wJhb4A0IsCPyFUKdlJlFwm', '$2y$10$AS0cf6OQ4RSi3x1Nk5PYPOwhZ.OD7q1wJhb4A0IsCPyFUKdlJlFwm', '2018-11-06 16:15:10', '2018-10-12', 'Adrian', 'Campos ', 'Oviedo', '113310539', 5, 'A', '113310539', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '88791556', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-10-13', 'Gerson', '3101727041'),
('acarmona', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-21 13:40:51', '2018-05-19', 'Alex', 'Carmona', 'Solano', '108420636', 5, 'A', '3101727041', 'acarmona', NULL, 'gguillen@masterzon.com', '89205080', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-19', 'Gerson', '3101727041'),
('acastillo', '$2y$10$8fxsa9siZGTnG//YdiZLaO9BpV.n1DlQvsYqaxSI6Rma4ugZzol6K', '$2y$10$8fxsa9siZGTnG//YdiZLaO9BpV.n1DlQvsYqaxSI6Rma4ugZzol6K', '2018-10-29 18:06:49', '2019-05-03', 'Alexander', 'Castillo', 'Morales', '601390623', 4, 'A', '3101117297', 'Diseno Arqcont S.A', NULL, 'gguillen@masterzon.com', '88297445', '', 'N', 'N', 'N', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-03', 'Francisco Ulate Azofeifa', '3101727041'),
('adeutschmann', 'TMP45617', '', NULL, '2018-08-17', 'Alejandro', 'Deutschmann', 'Samayoa', '132000085615', 1, 'P', '3101393948', 'Agrileasing Latinoamericano S. A.', NULL, 'gguillen@masterzon.com', '8892-6439', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-08-17', 'WEB', NULL),
('aelizondo', 'TMP28915', '', NULL, '2018-06-15', 'ADRIAN', 'ELIZONDO', 'ALVAREZ', '112090718', 1, 'P', '3101344857', 'NARA RESIDENCIAL 11 ESPINO', NULL, 'gguillen@masterzon.com', '83719854', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-06-15', 'WEB', NULL),
('agomez', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:17:48', '2019-05-10', 'ARELIS', 'GOMEZ', 'AGUILAR', '603340897', 5, 'A', '3002078587', 'ASECEMEX', NULL, 'gguillen@masterzon.com', '83688868', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('agomez87', '$2y$10$6ADEId9jJaaKHndqrwzfLeDArgOhJ9BSmD66/wIeNQA1rJayaSR7S', '$2y$10$6ADEId9jJaaKHndqrwzfLeDArgOhJ9BSmD66/wIeNQA1rJayaSR7S', '2018-11-07 10:44:11', '2019-05-10', 'ALFONSO', 'GOMEZ', 'MOLINA', '365638', 4, 'A', '3012682635', 'SEREOCARTO SL', NULL, 'gguillen@masterzon.com', '60809087', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-31', 'Gerson', '3101727041'),
('aguzman', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', NULL, '2019-06-19', 'Amelia', 'Guzman', 'Ulloa', '503050002', 5, 'A', '3002454356', 'ASEUNILEVER', NULL, 'gguillen@masterzon.com', '60911331', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-19', 'Francisco Ulate Azofeifa', '3101727041'),
('amendez', 'TMP75119', '', NULL, '2017-11-18', 'Alejandro ', 'Mendez', 'Varela', '6253224', 1, 'P', '3101537752', 'Terra Quimica s.a', NULL, 'gguillen@masterzon.com', '60557022', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2016-11-18', 'WEB', ''),
('amontero', 'TMP57023', '', NULL, '2018-02-22', 'Alvaro ', 'Montero', 'Morales ', '109060404', 1, 'P', '3102731561', 'Industrias de Bio-Elemntos S.R.L (In-Bio)', NULL, 'gguillen@masterzon.com', '72026049', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-02-22', 'WEB', ''),
('aobando', 'TMP68220', '', NULL, '2018-11-20', 'Andres', 'Obando', 'Valverde', '109470074', 1, 'P', '109470074', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '88366916', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-20', 'WEB', NULL),
('aoviedo', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:11:32', '2018-11-09', 'Alonso', 'Oviedo', 'Mora', '112630338', 4, 'A', '3101114047', 'CONSTRUCTORA PRESBERE SA', NULL, 'gguillen@masterzon.com', '89218537', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('apacheco', 'TMP33219', '', NULL, '2017-11-19', 'Alejandro', 'Pacheco', 'Coronado', '110210926', 1, 'P', '110210926', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '8923-0101', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2016-11-19', 'WEB', ''),
('apineda', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-07-18 13:01:36', '2019-05-10', 'ALLAN', 'PINEDA', 'OBANDO', '503040109', 4, 'A', '3101439852', 'LG Servicios Especializados S.A.', NULL, 'gguillen@masterzon.com', '88860624', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-12', 'Francisco Ulate Azofeifa', '3101727041'),
('apineda98', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', NULL, '2019-05-10', 'ALLAN', 'PINEDA', 'OBANDO', '05304109', 4, 'A', '3101223757', 'Corporacion Cenelec', NULL, 'gguillen@masterzon.com', '88860624', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-12', 'Francisco Ulate Azofeifa', '3101727041'),
('arodriguez', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 12:56:40', '2019-01-03', 'Ana Marcela', 'Rodri­guez', 'González', '108790951', 4, 'A', '3101697399', 'Constructora Proconsa', NULL, 'gguillen@masterzon.com', '88540710', '', 'N', 'N', 'S', 'S', '0.00', 365, 0, 0, 'N', 0, '2018-01-03', 'Francisco Ulate Azofeifa', '3101727041'),
('avalverde', 'An281170', '', NULL, '2019-05-10', 'ARACELLI', 'VALVERDE', 'SOLANO', '108920168', 4, 'I', '3101384104', 'INVERSIONES NATURARZA', NULL, 'gguillen@masterzon.com', '86722772', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-08', 'Jose Rivas', '3101727041'),
('avega', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-07-05 13:32:34', '2019-05-07', 'Ana Isabel', 'Vega', 'Martinez', '302900111', 4, 'A', '3101316814', 'GRUPO OROSI S.A.', NULL, 'gguillen@masterzon.com', '25925717', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Jose Rivas', '3101727041'),
('baguilar', '$2y$10$VtjR2hXmBrxwm4PEHrzP6uaOVExzs47ZPFAx6RXxmZh', '$2y$10$VtjR2hXmBrxwm4PEHrzP6uaOVExzs47ZPFAx6RXxmZhheW58CBAgu', NULL, '2019-07-10', 'Bernal', 'Aguilar', 'Cordero', '108200490', 4, 'P', '3101383592', 'Inmobiliaria Berliz S.A', NULL, 'gguillen@masterzon.com', '83837583', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-07-10', 'Francisco Ulate Azofeifa', '3101727041'),
('cbarahona', 'TMP87629', '', NULL, '2019-05-10', 'Carlos', 'Barahona', '', '108860420', 4, 'I', '3101690116', 'Sinocem Cota Rica SA', NULL, 'gguillen@masterzon.com', '25370082', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-08', 'Jose Rivas', '3101727041'),
('cbartels', '$2y$10$dOrQnqGo2UoTAnp2fTWvHe3XcwGmzU6I6fxQPfm5puNwgcQNvdRfa', '$2y$10$dOrQnqGo2UoTAnp2fTWvHe3XcwGmzU6I6fxQPfm5puNwgcQNvdRfa', '2018-11-08 12:57:15', '2019-02-28', 'CORNELIA', 'BARTELS', '', '152800006724', 5, 'A', '152800006724', 'Cuenta de persona fisica.', NULL, 'corabartels@hotmail.com\r\n', '88428080', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-13', 'Jose Rivas', '3101727041'),
('ccastro', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-24 09:25:07', '2018-11-29', 'CESAR', 'CASTRO', 'JIMENEZ', '303680661', 5, 'A', '3004045083', 'COOPETARRAZU R.L', NULL, 'gguillen@masterzon.com', '89138136', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-29', 'Francisco Ulate Azofeifa', '3101727041'),
('chernandez', 'TMP23115', '', NULL, '2019-02-15', 'Carlos', 'Hernandez', 'Cabrera', '107510294', 1, 'P', '3101300763', 'Distribuidora de Frutas, Carnes y Verduras Tres M,S.A.', NULL, 'gguillen@masterzon.com', '87619216', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-02-15', 'WEB', NULL),
('cmassey', '$2y$10$gpqZjNvFrRo55SQ/GTzRhejWsRrmqKeQ.8bBS4Lqnerbh0k4LtDCO', '$2y$10$gpqZjNvFrRo55SQ/GTzRhejWsRrmqKeQ.8bBS4Lqnerbh0k4LtDCO', '2018-10-29 16:00:04', '2018-11-06', 'Carlos', 'Massey', 'Fonseca', '106930838', 4, 'A', '3101376814', 'ADC MÃ³vil CRI S.A.', NULL, 'gguillen@masterzon.com', '22317275', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-07', 'Jose Rivas', '206440727'),
('cmora', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-06-12 16:48:22', '2017-05-31', 'Cris', 'Mora', 'Marin', '109360708', 4, 'A', '3101235381', 'Novus Mensajeria S.A.', NULL, 'gguillen@masterzon.com', '88967418', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('cnorman', 'Zamzam2017', '', NULL, '2019-05-10', 'Christopher', 'Norman', 'Paintiff', '800820648', 1, 'I', '800820648', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '89122003', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-08', 'Jose Rivas', '3101727041'),
('cperalta', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 12:52:00', '2019-05-10', 'Cesar ', 'Peralta', 'Hernandez', '801070063', 5, 'A', '801070063', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '71032778', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-13', 'Jose Rivas', '801070063'),
('cs', '$2y$10$0sS4rHOw2bLbcEVtOaFk4eFXaNbvuhA2u9tP0dFDRKxiCzIw/6XsO', '$2y$10$0sS4rHOw2bLbcEVtOaFk4eFXaNbvuhA2u9tP0dFDRKxiCzIw/6XsO', '2018-11-06 16:38:33', '2018-11-22', 'USUARIO', 'CS', '.', '110060486', 4, 'A', '3004045111', 'CS', NULL, 'gguillen@masterzon.com', '88570836', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '206440727'),
('csanchez', '52412695Ooop', '$2y$10$6nAtBtr/U2YcCG4CGJZaE.vAw.E7qi7.G/tn1CuD.ku9PDzFykdqW', NULL, '2019-05-10', 'CARMEN', 'SANCHEZ', '', '197924', 4, 'I', '3012682635', 'STEREOCARTO SL', NULL, 'gguillen@masterzon.com', '60272377', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-04-13', 'Gerson', '3101727041'),
('csolis', 'TMP50720', '', NULL, '2018-11-20', 'Carmelo Enrique', 'Solis', 'Jimenez', '110310902', 1, 'P', '110310902', 'Carmelo Enrique Solis Jimenez', NULL, 'gguillen@masterzon.com', '83518598', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-20', 'WEB', NULL),
('cumana', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:18:03', '2019-05-10', 'Carlos Alberto', 'Umana', 'Castillo', '303960354', 5, 'A', '3002078587', 'ASECEMEX', NULL, 'gguillen@masterzon.com', '87019768', '', 'N', 'S', 'S', 'N', '1000000.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('cvargas', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:07:37', '2018-03-14', 'CARLOS', 'VARGAS', 'LEITON', '601310715', 5, 'A', '300404508304', 'COOPETARRAZU R.L.', NULL, 'gguillen@masterzon.com', '83853173', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-28', 'Gerson', '3101727041'),
('dbrenes', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-06-20 11:44:54', '2019-01-25', 'Diego ', 'Brenes', 'Brenes', '304190562', 4, 'A', '3101172938', 'Constructora Hermanos Brenes S.A.', NULL, 'gguillen@masterzon.com', '83381516', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-09', 'Francisco Ulate Azofeifa', '3101727041'),
('dchinchilla', 'TMP50807', '', NULL, '2018-04-07', 'deivy ', 'chinchilla', 'mora', '113560145', 1, 'P', '3101172538', 'Termoclima CR SA', NULL, 'gguillen@masterzon.com', '85047849', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-04-07', 'WEB', NULL),
('dflores ', 'dafp0109', '', NULL, '2019-05-10', 'DIEGO ALONSO', 'FLORES', 'PORRAS', '111610555', 4, 'I', '3102635849', 'INDUMA', NULL, 'gguillen@masterzon.com', '71413922', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-25', 'Jose Rivas', '3101727041'),
('dgarro', 'TMP62015', '$2y$10$BeA67cpYlBGQAgstzUMqiuyQ34ty1jKAk3IsSFnukKdK51/0O2f8K', NULL, '2018-11-24', 'Randall', 'Garro', '', '1', 1, 'I', '3101127663', 'Creaciones Publicitarias Inter S.A.', NULL, 'gguillen@masterzon.com', '', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '801070063'),
('dmontenegro', '$2y$10$UEBCYow3oYCt423mzv43R.kNpG5bE5e73YygD1cgFd1', '$2y$10$UEBCYow3oYCt423mzv43R.kNpG5bE5e73YygD1cgFd1N8LYaSoUeq', NULL, '2019-07-12', 'Daniela ', 'Montenegro', 'Vargas', '2663147', 1, 'P', '3101395022', 'Inversiones Colmetex', NULL, 'gguillen@masterzon.com', '40340831', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-07-12', 'WEB', NULL),
('dmontenegro148', '$2y$10$h2uotJAuaBrYxMlkPfYamuQlcmm6uMOaUy8ggGYejTD', '$2y$10$h2uotJAuaBrYxMlkPfYamuQlcmm6uMOaUy8ggGYejTDgXkX0d/mgO', NULL, '2019-07-12', 'Daniela ', 'Montenegro', 'Vargas', '3101395022', 1, 'P', '3101395022', 'Inversiones Colmetex', NULL, 'gguillen@masterzon.com', '40340831', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-07-12', 'WEB', NULL),
('drobles', 'TMP51112', '', NULL, '2017-12-12', 'DAVID', 'ROBLES', 'RIVERA', '109700541', 1, 'P', '3101360943', 'SPEED CREDIT S.A.', NULL, 'gguillen@masterzon.com', '2219-0215', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2016-12-12', 'WEB', ''),
('ebrenes', 'TMP83227', '', NULL, '2019-05-10', 'Erick', 'Brenes', 'Vasquez', '302870479', 4, 'I', '3101265330', 'XISA Constructora SA', NULL, 'gguillen@masterzon.com', '25720973', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-08', 'Jose Rivas', '3101727041'),
('ecalderon ', 'TMP67117', '', NULL, '2017-12-17', 'Erick', 'Calderon ', 'Robles', '111790537', 1, 'P', '3101566261', 'Inversiones Calvo Calderon', NULL, 'gguillen@masterzon.com', '84109865', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2016-12-17', 'WEB', ''),
('ecastillo', 'TMP76101', '', NULL, '2018-03-01', 'Edwin', 'Castillo', 'Arias', '107730263', 1, 'P', '107730263', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '87038445', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-01', 'WEB', ''),
('efernandez', 'TMP47418', '', NULL, '2017-12-18', 'Emiliano', 'Fernandez', 'Segreda', '110910127', 1, 'P', '3101639600', 'Tellexcellence', NULL, 'gguillen@masterzon.com', '87031964', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2016-12-18', 'WEB', ''),
('eleon', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:02:00', '2019-05-10', 'EUGENIA ', 'LEON', 'MARENCO', '700620725', 4, 'A', '3101235381', 'NOVUS MENSAJERIA S.A.', NULL, 'gguillen@masterzon.com', '89199944', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-09', 'Francisco Ulate Azofeifa', '3101727041'),
('eoviedo', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:15:18', '2018-11-02', 'EDGAR', 'OVIEDO', 'BLANCO', '110110991', 5, 'A', '110110991', 'EDGAR OVIEDO BLANCO', NULL, 'gguillen@masterzon.com', '88751011', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-02', 'Francisco Ulate Azofeifa', '3101727041'),
('erobles', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:07:26', '2018-11-29', 'EDDY', 'ROBLES', 'JIMENEZ', '900940400', 5, 'A', '3004045083', 'COOPETARRAZU R.L', NULL, 'gguillen@masterzon.com', '83143091', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-29', 'Francisco Ulate Azofeifa', '3101727041'),
('erojas ', '$2y$10$nwhjxXJuMMXNXCBVlulZB.SfAYAgC9vF94zF99jcFwmm487dAR./y', '$2y$10$nwhjxXJuMMXNXCBVlulZB.SfAYAgC9vF94zF99jcFwmm487dAR./y', '2018-11-08 10:57:14', '2019-05-10', 'ELIO', 'ROJAS', 'ROJAS', '109260511', 5, 'A', '152800006724', 'Cuenta de persona fisica.', NULL, 'eliorojas7@gmail.com', '83175053', '', 'N', 'N', 'S', 'N', '0.00', 360, 0, 0, 'N', 0, '2017-05-22', 'Gerson', '3101727041'),
('evargas', 'j9zg4r', '', NULL, '2019-05-10', 'Esteban', 'Vargas', 'Gomez ', '11058037', 5, 'I', '11058037', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '88249590', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-06', 'Francisco Ulate Azofeifa', '3101727041'),
('evillalobos', '$2y$10$pp0GQI3yYK208TuB4quBpu4USqj9so7OL6jqDbGZwyE', '$2y$10$pp0GQI3yYK208TuB4quBpu4USqj9so7OL6jqDbGZwyESYx346wdee', NULL, '2019-06-24', 'Erick', 'Villalobos', 'Alvarez', '204770156', 1, 'P', '3101655669', 'Excelencia en Servicios IT y Outsourcing', NULL, 'gguillen@masterzon.com', '88193290', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-24', 'WEB', NULL),
('fdelgado', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-12 11:08:55', '2018-10-31', 'Francini', 'Delgado', 'Carvajal', '111760352', 5, 'A', '3004045205', 'COOPENAE', NULL, 'gguillen@masterzon.com', '87129285', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('fgomez ', '08062007', '', NULL, '2018-11-22', 'Francisco ', 'Gomez ', 'Gomez ', '111210642', 4, 'P', '3101225198', 'Constructora Contek SA', NULL, 'gguillen@masterzon.com', '22723000', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-04-16', 'Jose Rivas', '3101727041'),
('fhernandez', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:18:55', '2019-04-09', 'Francisco', 'Hernandez', 'Valladares', '700910815', 5, 'A', '3002078847', 'ASEDEMASA', NULL, 'gguillen@masterzon.com', '83272431', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-04-10', 'Francisco Ulate Azofeifa', '3101727041'),
('flopez', 'TMP2119', '', NULL, '2017-12-19', 'Fernando ', 'López', 'Pérez', '600880531', 1, 'P', '600880531', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '88830600', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2016-12-19', 'WEB', ''),
('fmolina', 'TMP45714', '', NULL, '2018-11-14', 'Francisco', 'Molina', 'Castro', '115240900', 1, 'P', '115240900', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '88250375', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-14', 'WEB', NULL),
('fmora', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:11:48', '2019-04-30', 'Francisco', 'Mora', 'Rojas', '601560512', 4, 'A', '3101117297', 'Diseno Arqcont S.A', NULL, 'gguillen@masterzon.com', '83836068', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-03', 'Francisco Ulate Azofeifa', '3101727041'),
('fsoto', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:12:56', '2018-10-19', 'Francisco', 'Soto', 'Sagot', '107830445', 4, 'A', '3101151258', 'Chaso del Valle S.A.', NULL, 'gguillen@masterzon.com', '83813203', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '206440727'),
('fulate', '$2y$10$0fZGkysGCG9AfHlHKW.VzOCXFFjSs2FEo/4QnGISelmmMnXrB5CKG', '$2y$10$0fZGkysGCG9AfHlHKW.VzOCXFFjSs2FEo/4QnGISelmmMnXrB5CKG', '2018-11-08 09:36:23', '2019-05-10', 'Francisco', 'Ulate', 'Azofeifa', '401610041', 5, 'A', '3101727041', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '83754845', '', 'N', 'S', 'S', 'N', '1000000.00', 365, 0, 0, 'N', 0, '2017-12-06', 'Francisco Ulate Azofeifa', '3101727041'),
('fvargas', 'octubrerojo', '', NULL, '2018-04-06', 'FRANCISCO', 'VARGAS', 'SOLANO', '106120098', 4, 'I', '3102734076', 'ECHANDI, VARGAS Y ASOCIADOS SRL', NULL, 'gguillen@masterzon.com', '83024226', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-08', 'Jose Rivas', '3101727041'),
('gchevez', 'TMP59523', '', NULL, '2018-01-23', 'Gerardo', 'Chevez', 'Alvares', '103961079', 1, 'P', '310124679500', 'Grupo Chevez Zamora S.A', NULL, 'gguillen@masterzon.com', '22964996', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-02-22', 'Jose Rivas', ''),
('gguillen', '$2y$10$e4wwLCuxqAstjGjFwuEuF.Ez98YkdpyU7dxts/iZg.7SvAMrglS/G', '$2y$10$e4wwLCuxqAstjGjFwuEuF.Ez98YkdpyU7dxts/iZg.7SvAMrglS/G', '2018-11-08 10:20:58', '2017-05-01', 'GERSON', 'GUILLEN', 'SOLANO', '110000867', 4, 'A', '3101727041', 'MASTERZON CR SA', NULL, 'gguillen@masterzon.com', '60661010', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-04-04', 'Gerson', '3101727041'),
('gmarin', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:03:32', '2019-01-30', 'GERARDO', 'MARIN', 'CARMONA', '900640101', 4, 'A', '3101316814', 'GRUPO OROSI S.A.', NULL, 'gguillen@masterzon.com', '70149297', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('gmelendez', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-20 14:47:15', '2019-06-19', 'Gabriel', 'Melendez', 'Montero', '113970427', 5, 'A', '3002454356', 'ASEUNILEVER', NULL, 'gguillen@masterzon.com', '87074895', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-19', 'Francisco Ulate Azofeifa', '3101727041'),
('gobando ', '$2y$10$2tAqPIaFmmSUcGvxU7769Ou.Q25fNdqDwgxMffiJDPu', '$2y$10$2tAqPIaFmmSUcGvxU7769Ou.Q25fNdqDwgxMffiJDPu/ZxbezG05u', NULL, '2019-07-09', 'GERARDO  ', 'OBANDO ', 'ALVAREZ', '503100082', 1, 'P', '3101586136', 'AUTO LAVADO LA PLAYA S.A ', NULL, 'gguillen@masterzon.com', '2665-6511', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-07-09', 'WEB', NULL),
('gporras', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-16 11:10:56', '2019-05-10', 'Grettel ', 'Porras', '', '401740272', 5, 'A', '3002396430', 'ASEBOSTON', NULL, 'gguillen@masterzon.com', '89315069', '', 'N', 'S', 'N', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('grodriguez', 'grp1822539', '', NULL, '2019-05-10', 'GERARDO ', 'RODRIGUEZ', 'PEREZ', '1822539', 4, 'I', '3101127663', 'Creaciones Publicitarias Inter S.A', NULL, 'gguillen@masterzon.com', '88499277', '', 'N', 'S', 'S', 'S', '0.00', 365, 0, 0, 'N', 0, '2018-01-18', 'Jose Rivas', '3101727041'),
('grojas', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-06-28 08:44:57', '2019-02-05', 'Giovanni', 'Rojas', 'Vargas', '111270525', 4, 'A', '3101702806', 'Propallet S.A', NULL, 'gguillen@masterzon.com', '84232205', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-03-05', 'Francisco Ulate Azofeifa', '3101727041'),
('gsanchez', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-07-13 12:17:31', '2019-04-04', 'Guillermo Antonio', 'Sanchez', 'Cubillo', '107990962', 4, 'A', '3101225198', 'Constructora Contek S.A.', NULL, 'gguillen@masterzon.com', '83805589', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-04-04', 'Jose Rivas', '206440727'),
('gumana', 'TMP60328', '', NULL, '2019-02-28', 'Gerardo Antonio', 'Umana', 'Rojas', '106540792', 1, 'P', '3101511598', 'Asesores Sysynfo S.A', NULL, 'gguillen@masterzon.com', '88234412', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-02-28', 'WEB', NULL),
('gzamora', 'TMP54215', '', NULL, '2018-12-15', 'Graciela', 'Zamora', 'ChacÃ³n', '111180313', 1, 'P', '3002152430', 'ASEHNN', NULL, 'gguillen@masterzon.com', '22480760', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-12-15', 'WEB', NULL),
('harburola', '$2y$10$eznLVpJUTYY9.HqafKfD9.c/eRISPerLrlNWLG6C.2g65P4H68AsK', '$2y$10$eznLVpJUTYY9.HqafKfD9.c/eRISPerLrlNWLG6C.2g65P4H68AsK', '2018-11-06 15:53:48', '2019-01-30', 'HILARY', 'ARBUROLA', 'BARRANTES', '112640433', 4, 'A', '3004045027', 'COOPEANDE 1', NULL, 'gguillen@masterzon.com', '70708635', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('hbermudez', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-20 09:38:27', '2018-10-06', 'Heidy Maria', 'Bermudez', 'Flores', '108550656', 5, 'A', '3002075697', 'ASDEPSA', NULL, 'gguillen@masterzon.com', '87201793', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-23', 'Jose Rivas', '3101727041'),
('hbrenes', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 12:58:32', '2019-01-25', 'Hugo', 'Brenes', 'Gonzalez', '301970458', 4, 'A', '3101172938', 'Constructora Hermanos Brenes S.A.', NULL, 'gguillen@masterzon.com', '88785163', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-25', 'Jose Rivas', '3101727041'),
('hed', 'TMP36127', '', NULL, '2018-03-27', 'heiner', 'ed', 'hd', '205980186', 1, 'P', '3101693486', 'ICM consultores ', NULL, 'gguillen@masterzon.com', '71955144', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-27', 'WEB', NULL),
('iportocarrero', 'TMP43627', '', NULL, '2018-02-26', 'Isaac', 'Portocarrero', 'Mora', '115660161', 1, 'P', '3101701878', 'GoPass', NULL, 'gguillen@masterzon.com', '83165070', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-02-26', 'WEB', ''),
('jalvarado', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:10:11', '2018-12-06', 'Jose Rolando', 'Alvarado', 'Avellán', '601820513', 4, 'A', '3101081676', 'Axioma Internacional S.A', NULL, 'gguillen@masterzon.com', '88304100', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-09', 'Francisco Ulate Azofeifa', '3101727041'),
('jbrenes', 'TMP15616', '', NULL, '2018-05-16', 'Jonnathan', 'Brenes', 'VÃ­quez', '109420695', 1, 'P', '3101323196', 'Esterymatec', NULL, 'gguillen@masterzon.com', '22203411', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-16', 'WEB', NULL),
('jbrenes288', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 12:59:54', '2019-01-25', 'Jorge', 'Brenes', 'Gonzalez', '302060808', 4, 'A', '3101172938', 'Constructora Hermanos Brenes S.A.', NULL, 'gguillen@masterzon.com', '25737373', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-25', 'Jose Rivas', '3101727041'),
('jbruno', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 12:56:58', '2019-01-03', 'Jorge', 'Bruno', 'Arguedas', '107340990', 4, 'A', '3101697399', 'Constructora Proconsa', NULL, 'gguillen@masterzon.com', '88824924', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-03', 'Francisco Ulate Azofeifa', '3101727041'),
('jcasasola ', 'TMP61702', '', NULL, '2018-05-01', 'JosÃ© Antonio ', 'Casasola ', 'Gonzalez', '3215463', 1, 'P', '3101132167', 'Tecnocomputo NV, S.A', NULL, 'gguillen@masterzon.com', '2202-8900', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-01', 'WEB', NULL),
('jcorrales', '$2y$10$yuUm6k8GozgNHUhsommaMOEBFmYiX/Ti/c0PNZCZbYwGyeMkCPgnO', '$2y$10$yuUm6k8GozgNHUhsommaMOEBFmYiX/Ti/c0PNZCZbYwGyeMkCPgnO', '2018-11-06 16:29:35', '2017-05-31', 'Johnny', 'Corrales', 'Solano', '106800735', 5, 'A', '3002396430', 'ASEBOSTON', NULL, 'gguillen@masterzon.com', '88119024', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-03', 'Gerson', '3101727041'),
('jcruz', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-07-11 10:54:47', '2018-11-15', 'Jorge', 'Cruz', 'Vega', '108550378', 4, 'A', '3101127663', 'Creaciones Publicitarias Inter S.A.', NULL, 'gguillen@masterzon.com', '83739384', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-12-12', 'Francisco Ulate Azofeifa', '3101727041'),
('jcuadra', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:00:06', '2019-02-20', 'Jose', 'Cuadra', 'Arroyo', '205280834', 4, 'A', '3101200102', 'CONSTRUCTORA PENARANDA S.A', NULL, 'gguillen@masterzon.com', '86614792', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-09', 'Francisco Ulate Azofeifa', '3101727041'),
('jgonzalez', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:05:35', '2018-07-27', 'Juan M ', 'Gonzalez ', 'Zamora', '400920565', 4, 'A', '31014036495', 'PRO IN MSA', NULL, 'gguillen@masterzon.com', '22559988', NULL, 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-07-27', 'dba', '3101727041'),
('jhernandez ', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-06-13 13:40:31', '2019-05-15', 'Jose Alejandro', 'Hernandez ', 'Contreras', '186200221426', 4, 'A', '3101670939', 'v-net comunicaciones s.a', NULL, 'gguillen@masterzon.com', '88722501', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-15', 'Jose Rivas', '3101727041'),
('jherrera', '$2y$10$A8/gu4QiQ1Zx1PFjNOX.DuYP7raxTG5/ohVUMkD7JJh', '$2y$10$A8/gu4QiQ1Zx1PFjNOX.DuYP7raxTG5/ohVUMkD7JJhxOzcPsK9I6', NULL, '2019-07-09', 'Juan Carlos ', 'Herrera', 'Herrera', '155812716817', 1, 'P', '3102457983', 'Taller Industrial Rojas y Herrera Ltda', NULL, 'gguillen@masterzon.com', '506 8915-9317', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-07-09', 'WEB', NULL),
('jmasis', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-23 18:12:31', '2018-11-03', 'Julio', 'Masis', 'Jimenez', '108110682', 4, 'A', '3101562914', 'Rivering de Costa Rica S.A.', NULL, 'gguillen@masterzon.com', '89196961', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('jmatarrita', 'TMP56414', '', NULL, '2018-06-14', 'Julio Cesar', 'Matarrita', 'Sibaja', '603920452', 1, 'P', '603920452', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '83099545', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-06-14', 'WEB', NULL),
('jobando ', '$2y$10$Fy30a2fpH.SrHcO9G8nZf.nijyfClIWwdGemD1VxN7Y', '$2y$10$Fy30a2fpH.SrHcO9G8nZf.nijyfClIWwdGemD1VxN7YPx7CPhSBku', NULL, '2019-06-27', 'JUANCARLOS ', 'Obando ', 'Zuniga', '203920483', 1, 'P', '3101472019', 'Servicios integrados aduanales shekina s.a', NULL, 'gguillen@masterzon.com', '5062215 4328', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-27', 'WEB', NULL),
('jpage', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-04 08:57:40', '2019-02-28', 'Jessica', 'Page', 'Pastrano', '205410752', 5, 'A', '3002204388', 'AsoSYKES', NULL, 'gguillen@masterzon.com', '83317376', '', 'N', 'N', 'S', 'N', '1000000.00', 90, 0, 0, 'N', 0, '2018-02-28', 'Francisco Ulate Azofeifa', '3101727041'),
('jreyna', 'TMP49219', '', NULL, '2018-05-19', 'JAVIER', 'REYNA', 'DOBLES', '105680729', 1, 'P', '3101406800', 'IRR LOGISTICS S.A.', NULL, 'gguillen@masterzon.com', '83962311', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-19', 'WEB', NULL),
('jrivas', '$2y$10$wpHweuPrvW4mU6NdntsV0ezE3XhPEMboF..r6gAqkS//UpBq5YqC.', '$2y$10$wpHweuPrvW4mU6NdntsV0ezE3XhPEMboF..r6gAqkS//UpBq5YqC.', '2018-11-08 09:14:04', '2019-05-10', 'Jose', 'Rivas', 'Ramirez', '206440727', 6, 'A', '3101677940', 'Masterzon', NULL, 'jrivas@brokerscapitalcr.com\r\n', '89100542', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-04-04', 'Gerson', '3101727041'),
('jrodriguez', 'TMP91212', '', NULL, '2019-02-11', 'Jose Pablo', 'Rodriguez', 'Chaves', '206530872', 1, 'P', '206530872', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '89928230', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-02-11', 'WEB', NULL),
('jsalas', 'Portugal1', '', NULL, '2019-05-10', 'JOSE ', 'SALAS', 'MOLINA', '204890363', 4, 'I', '3101320803', 'JCBCONSTRUCTORA Y ALQUILER S.A.', NULL, 'gguillen@masterzon.com', '22909497', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-09-20', 'Jose Rivas', '3101727041'),
('jsalguero', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 12:55:50', '2019-02-05', 'Juan Diego', 'Salguero', 'Valverde', '113400375', 4, 'A', '3101702806', 'Propallet S.A', NULL, 'gguillen@masterzon.com', '24301980', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-02-05', 'Francisco Ulate Azofeifa', '3101727041'),
('jsolano', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:13:51', '2018-11-14', 'Jairo', 'Solano', 'Monge', '109120257', 5, 'A', '109120257', 'Jairo Solano Monge', NULL, 'gguillen@masterzon.com', '88739191', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-14', 'Francisco Ulate Azofeifa', '3101727041'),
('jsolano 82', 'TMP33309', '', NULL, '2019-01-08', 'JESÃšS ', 'Solano ', 'Milenio ', '000000000000', 1, 'P', 'Xxxxxxxxxx', 'Licores nuevo milenio ', NULL, 'gguillen@masterzon.com', '0000000000', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-08', 'WEB', NULL),
('jty3140700', 'TMP4126', '', NULL, '2018-10-26', 'j', 'ty3140700', 'ty3140700', 'kahan y', 1, 'P', 'my', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '+972533140700', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-10-26', 'WEB', NULL),
('julloa', '$2y$10$dTmAaLSOG5iPnNKLmW1xcOdNVTMYyN1cXykwl.F.Rb/ohSxL2tjkO', '$2y$10$dTmAaLSOG5iPnNKLmW1xcOdNVTMYyN1cXykwl.F.Rb/ohSxL2tjkO', '2018-10-29 13:04:40', '2018-11-29', 'JENNIFER ', 'ULLOA', 'JIMENEZ', '115900400', 4, 'A', '3004045083', 'COOPETARRAZU R.L', NULL, 'gguillen@masterzon.com', '89816521', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-29', 'Francisco Ulate Azofeifa', '3101727041'),
('karaya', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-07-20 14:42:28', '2019-01-30', 'KATTYA', 'ARAYA', 'MARTINEZ', '303130952', 4, 'A', '3101316814', 'GRUPO OROSI S.A.', NULL, 'gguillen@masterzon.com', '88904212', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-03', 'Gerson', '3101727041'),
('kchinchilla', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:10:42', '2019-05-10', 'KATHYA', 'CHINCHILLA', 'FERNANDEZ', '111350250', 4, 'A', '3101098063', 'MUTIASA ', NULL, 'gguillen@masterzon.com', '25422006', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-16', 'Jose Rivas', '3101727041'),
('kflores', 'TMP60711', '', NULL, '2019-03-10', 'Karol', 'Flores', 'Hernandez ', '303570865', 1, 'P', '3101727694', 'Granja AvÃ­cola Organica de Tilaran ', NULL, 'gguillen@masterzon.com', '83041020', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-03-10', 'WEB', NULL),
('ksanchez', 'SAKA2510', '$2y$10$TR9qjPMvUPr33jcvTeCOJexXhx0jacNfpYJxp94Xw21enHpHFSKS6', NULL, '2018-08-09', 'Karina', 'Sanchez', '', '113040535', 4, 'I', '3101320803', 'JCBCONSTRUCTORA Y ALQUILER S.A.', NULL, 'gguillen@masterzon.com', '22960082', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-03-14', 'Francisco Ulate Azofeifa', '3101727041'),
('lfonseca', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-11-02 13:01:50', '2019-04-09', 'Lorena', 'Fonseca', 'Zuniga', '401260010', 5, 'A', '3002078847', 'ASEDEMASA', NULL, 'gguillen@masterzon.com', '89399137', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-04-10', 'Francisco Ulate Azofeifa', '3101727041'),
('lgonzales', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 12:53:35', '2019-01-31', 'LEONEL', 'GONZALES', 'HIDALGO', '111170611', 4, 'A', '3102372096', 'PROMEDICAL DE CR SRL', NULL, 'gguillen@masterzon.com', '83593626', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-31', 'Jose Rivas', '3101727041'),
('lleon', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:02:14', '2019-05-10', 'LUBADINIA', 'LEON', 'MARENCO', '700700101', 4, 'A', '3101235381', 'NOVUS MENSAJERIA S.A.', NULL, 'gguillen@masterzon.com', '83385566', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-09', 'Francisco Ulate Azofeifa', '3101727041'),
('lquesada', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-08-06 10:00:38', '2019-07-18', 'Luis Diego', 'Quesada', 'Madrigal', '303560702', 4, 'A', '3101493379', 'INVERSIONES MADRIQUE S.A', NULL, 'gguillen@masterzon.com', '70705222', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-07-18', 'Francisco Ulate Azofeifa', '3101727041'),
('lsalguera', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:09:52', '2019-05-10', 'Lisbeth', 'Salguera', 'Calvo', '109250126', 5, 'A', '3101063817', 'Temafra SA', NULL, 'gguillen@masterzon.com', '22481745', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-22', 'Gerson', '3101727041'),
('lvega', 'Delta2017', '', NULL, '2017-04-19', 'LAURA', 'VEGA', 'CHAVARRIA', '105550939', 4, 'I', '3101213117', 'COMANDOS DE SEGURIDAD DELTA S.A.', NULL, 'gguillen@masterzon.com', '40352135', 'COMANDOS DE SEGURIDAD DELTA S.A.', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-01-08', 'Jose Rivas', '3101727041'),
('maguero', '$2y$10$471vK6cTY2iUGSuOkPvSouRcGXJZLtZU/kEtDgp6hK84qvwozj5wa', '$2y$10$471vK6cTY2iUGSuOkPvSouRcGXJZLtZU/kEtDgp6hK84qvwozj5wa', '2018-10-29 13:06:04', '2018-09-12', 'Manfred', 'Aguero', 'Delgado', '602400141', 4, 'A', '3004045205', 'COOPENAE', NULL, 'gguillen@masterzon.com', '87206108', '', 'N', 'S', 'S', 'N', '0.00', 45, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('maguero104', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:15:00', '2018-12-13', 'Manfed', 'Aguero', 'Delgado', '109500718', 5, 'A', '109500718', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '87206108', '', 'N', 'S', 'S', 'N', '1000000.00', 120, 0, 0, 'N', 0, '2017-12-13', 'Gerson', '3101727041'),
('marguedas ', '$2y$10$/uQFZFM3hsnWfEGbg6w0PO16ISGHL1GYdxW1/Ay8bPb', '$2y$10$/uQFZFM3hsnWfEGbg6w0PO16ISGHL1GYdxW1/Ay8bPbLdf4ZUX9Zq', '2018-05-19 12:27:12', '2019-05-10', 'Manuel Enrique', 'Arguedas ', 'Venegas', '104131393', 6, 'A', '104131393', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '83507166', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-13', 'Jose Rivas', '3101727041'),
('mbolanos', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-23 13:05:32', '2019-05-21', 'Maria Isabel', 'Bolanos', 'Murillo', '401240207', 5, 'A', '3002702894', 'ASOA', NULL, 'gguillen@masterzon.com', '87146388', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-21', 'Francisco Ulate Azofeifa', '3101727041'),
('mbrusiur', '$2y$10$If70bUuPvrrpynlCYtVrueTgod1YtiMWAyr0cpmLU55', '$2y$10$If70bUuPvrrpynlCYtVrueTgod1YtiMWAyr0cpmLU55t4z5ARXcxy', '2018-05-19 13:03:02', '2019-05-10', 'Marcus Fred.', 'Brusius', '', '25193331', 10, 'A', '3101260434', 'Hamburg Sud', NULL, 'gguillen@masterzon.com', '25193331', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-19', 'Gerson', '3101727041'),
('mcastro', 'Manu1212', '', NULL, '2018-01-24', 'Manuel', 'Castro', 'Sanchez', '110080199', 1, 'P', '3101526083', 'Inversiones Tierra Nuestra del Sol K&M S.A.', NULL, 'gguillen@masterzon.com', '88215561', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-01-24', 'WEB', ''),
('mcharpentier', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:11:16', '2019-05-10', 'Maria Beatrice', 'Charpentier', 'Celano', '901050404', 4, 'A', '3101098063', 'Mutiasa', NULL, 'gguillen@masterzon.com', '72006600', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-07-07', 'Jose Rivas', '3101727041'),
('mcortes', 'Nico2017', '$2y$10$GEWVdPDHTw0dGnuZpmiG/.WNaKju1gx1CKcMZagPkxvmgtu2leZFe', NULL, '2018-08-09', 'Mario', 'Cortes', '', '601920208', 4, 'I', '3101320803', 'JCBCONSTRUCTORA Y ALQUILER S.A.', NULL, 'gguillen@masterzon.com', '22960082', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-03-14', 'Francisco Ulate Azofeifa', '3101727041'),
('mgarcia', 'TMP93831', '', NULL, '2018-03-31', 'Michelle', 'Garcia', 'Campos', '115450254', 1, 'P', '115450254', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '86057105', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-31', 'WEB', NULL),
('mhernandez', 'TMP26628', '', NULL, '2018-03-28', 'Ma. de los Angeles ', 'Hernandez', 'Hernandez', '302040516', 1, 'P', '3101228226', 'CorporaciÃ³n Mather S-A', NULL, 'gguillen@masterzon.com', '71939764', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-28', 'WEB', NULL),
('mjimenez ', 'TMP61628', '', NULL, '2018-09-27', 'Miguel ', 'Jimenez ', 'RodrÃ­guez ', '106120472', 1, 'P', '3101142660', 'New Medical S.A', NULL, 'gguillen@masterzon.com', '40018435', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-09-27', 'WEB', NULL),
('mmontero', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-07-13 08:25:54', '2019-05-10', 'Mary Cruz', 'Montero ', 'Cespedes', '304170509', 4, 'A', '3101172938', 'Constructora Hermanos Brenes, S.A.', NULL, 'gguillen@masterzon.com', '87556969', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('mmorales', 'TMP60727', '', NULL, '2018-12-26', 'Manuel', 'Morales', 'Morales', '110610737', 1, 'P', '110610737', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '83736453', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-12-26', 'WEB', NULL),
('mmorales359', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-07-17 10:58:01', '2019-02-28', 'Marilyn ', 'Morales', 'Serrano', '303740744', 4, 'A', '3102372096', 'promedical', NULL, 'gguillen@masterzon.com', '89925522', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-02-28', 'Francisco Ulate Azofeifa', '801070063'),
('mobando', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:08:59', '2018-10-21', 'Melina', 'Obando', 'Salas', '304150114', 5, 'A', '304150114', 'Melina Obando Salas', NULL, 'gguillen@masterzon.com', '88975125', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-10-22', 'Francisco Ulate Azofeifa', '206440727'),
('morganista', 'Gata1579', '', NULL, '2018-01-27', 'maritza ', 'organista', 'diaz', '800960844', 1, 'P', '3101701112', 'armadillo diseÃ±o y btl s.a.', NULL, 'gguillen@masterzon.com', '70104207', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-02-14', 'Jose Rivas', ''),
('mpenaranda', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:00:25', '2019-02-20', 'Marco', 'Penaranda', 'Chinchilla', '401500070', 4, 'A', '3101200102', 'CONSTRUCTORA PENARANDA S.A', NULL, 'gguillen@masterzon.com', '24450254', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-02-20', 'Francisco Ulate Azofeifa', '3101727041'),
('mphillips', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:16:54', '2019-05-10', 'MARIANELA', 'PHILLIPS', 'AGUILAR', '105900864', 5, 'A', '152800006724', 'Cornelia Maria Magdalena BARTELS', NULL, 'gguillen@masterzon.com', '87129596', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-13', 'Jose Rivas', '3101727041'),
('mramirez', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-20 10:05:45', '2018-10-10', 'mario jose', 'ramirez', 'aguilar', '108850253', 5, 'A', '108850253', 'Mario Ramirez', NULL, 'gguillen@masterzon.com', '83993622', '', 'N', 'S', 'S', 'N', '1000000.00', 365, 0, 0, 'N', 0, '2017-11-28', 'Gerson', '3101727041'),
('mreyes', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 12:57:33', '2019-05-10', 'MARIA ISABEL', 'REYES', 'ALVAREZ', '800930430', 4, 'A', '3101615701', 'SPINE CR S.A', NULL, 'gguillen@masterzon.com', '88679323', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-19', 'Gerson', '3101727041'),
('mrivera', '$2y$10$4acrzvTYyDdR2jXzhrc1tukr.OHQ43f4aS2Uhl2OWXO', '$2y$10$4acrzvTYyDdR2jXzhrc1tukr.OHQ43f4aS2Uhl2OWXOZasoKLtCim', '2018-05-19 13:02:28', '2019-05-10', 'Maria', 'Rivera', '', '25193314', 10, 'A', '3101260434', 'Hamburg Sud', NULL, 'gguillen@masterzon.com', '25193314', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-19', 'Gerson', '3101727041'),
('msalas', 'TMP68610', '', NULL, '2019-05-10', 'MAUREEN', 'SALAS', 'ARBUROLA', '205580010', 5, 'I', '3002454356', 'ASEUNILEVER', NULL, 'gguillen@masterzon.com', '83334808', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-19', 'Francisco Ulate Azofeifa', '3101727041'),
('msatger', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-23 07:40:36', '2019-05-10', 'michel', 'satger', '', '125000094724', 5, 'A', '125000094724', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '83133334', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-18', 'Gerson', '3101727041'),
('mserrano', 'TMP28108', '', NULL, '2019-02-08', 'Max', 'Serrano', 'DurÃ¡n', '110360450', 1, 'P', '310109284', 'Veromatic', NULL, 'gguillen@masterzon.com', '83624236', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-02-08', 'WEB', NULL),
('msoto', 'TMP78030', '', NULL, '2018-03-30', 'Marvin', 'Soto', 'Gutierrez', '3101417934', 1, 'P', 'Yostek', 'Tecnologia Del Este Leon Romero ', NULL, 'gguillen@masterzon.com', '27989045', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-30', 'WEB', NULL),
('mviquez ', 'TMP51521', '', NULL, '2018-04-21', 'Mario ', 'Viquez ', 'Alfaro ', '401620920', 1, 'P', '401620920', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '88606743', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-04-21', 'WEB', NULL),
('nguiller', 'TMP79420', '', NULL, '2018-12-20', 'Nicolas', 'Guiller', 'Chaves', '1 1803 0131', 1, 'P', '301123456', 'Nombre de la empresa', NULL, 'gguillen@masterzon.com', '8428 5195', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-12-20', 'WEB', NULL),
('oesquetini', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:10:25', '2019-05-10', 'Oscar', 'Esquetini', 'Flor', '121800046512', 4, 'A', '3101081676', 'Axioma Internacional, S. A.', NULL, 'gguillen@masterzon.com', '88164348', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-04', 'Gerson', '3101727041');
INSERT INTO `sis_usuarios` (`cod_usuario`, `cod_clave`, `cod_token`, `fec_hora_fin_sesion`, `fec_vencimiento`, `des_nombre`, `des_apellido1`, `des_apellido2`, `num_identificacion`, `cod_perfil`, `ind_estado`, `cod_compania`, `des_compania`, `des_foto`, `des_email`, `num_telefono`, `des_link_red_social`, `ind_alertas_nuevos`, `ind_alertas_cambios`, `ind_alertas_sms_cambios`, `ind_cierre_bloqueo_operaciones`, `mon_minimo_filtro_facial`, `num_maximo_filtro_plazo`, `ind_filtro_sector`, `ind_filtro_moneda`, `ind_filtro_propias`, `ind_filtro_tipoNegocio`, `fec_creacion`, `cod_usuario_creacion`, `num_cedula`) VALUES
('ogei', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-06-21 08:43:18', '2019-06-20', 'Orlando', 'Gei', 'Brealey', '106690153', 4, 'A', '3101254525', 'Estruconsult S.A', NULL, 'gguillen@masterzon.com', '83844479', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-20', 'Francisco Ulate Azofeifa', '3101727041'),
('omarin', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:00:44', '2018-11-22', 'Oscar ', 'Marin ', 'Zamora', '108010458', 4, 'A', '3101225198', 'Constructora Contek SA', NULL, 'gguillen@masterzon.com', '60593251', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('pbonilla', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:17:11', '2018-10-06', 'Percy', 'Bonilla', 'Lopez', '401620275', 5, 'A', '3002075697', 'ASDEPSA', NULL, 'gguillen@masterzon.com', '88265443', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-10-06', 'Jose Rivas', '3101727041'),
('pdelgado', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-11 08:40:40', '2019-04-09', 'Pamela', 'Delgado', 'Guadamuz', '109500684', 5, 'A', '3002078847', 'ASEDEMASA', NULL, 'gguillen@masterzon.com', '83190625', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-04-10', 'Francisco Ulate Azofeifa', '3101727041'),
('pmoreno', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-23 11:08:00', '2018-11-22', 'Priscilla', 'Moreno', 'Martinez', '107670030', 5, 'A', '3002662958', 'ASEMOPT', NULL, 'gguillen@masterzon.com', '88244338', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-08', 'Francisco Ulate Azofeifa', '3101727041'),
('pprueba', 'TMP35519', '', NULL, '2018-02-19', 'prueba', 'prueba', 'prueba', '101', 1, 'P', '12', 'a', NULL, 'gguillen@masterzon.com', '123', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-02-19', 'WEB', ''),
('promero', 'TMP66519', '', NULL, '2018-05-19', 'PABLO', 'ROMERO', 'DOBLES', '106090793', 1, 'P', '3101406800', 'IRR LOGISTICS S.A.', NULL, 'gguillen@masterzon.com', '83090707', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-19', 'WEB', NULL),
('rcalvo', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-06-28 08:39:01', '2019-01-22', 'RANDALL', 'CALVO', 'MELENDEZ', '108170275', 4, 'A', '3101702806', 'PROPALLET, S.A.', NULL, 'gguillen@masterzon.com', '83227786', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-03-05', 'Francisco Ulate Azofeifa', '3101727041'),
('rcantillano', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 12:55:32', '2018-09-29', 'ROY', 'CANTILLANO', 'GONZALEZ', '109540130', 4, 'A', '3101719704', 'EQUIPOS TACTICOS Y DE RESCATE', NULL, 'gguillen@masterzon.com', '88923613', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-09-29', 'Francisco Ulate Azofeifa', '206440727'),
('rcarrillo', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 13:14:25', '2018-10-12', 'Rodolfo', 'Carrillo', 'Mena', '109460803', 5, 'A', '109460803', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '60508898', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-10-13', 'Jose Rivas', '3101727041'),
('rcarvajal', 'TMP9031', '', NULL, '2018-03-31', 'Rigoberto Javier', 'Carvajal', 'Quiros', '106010375', 1, 'P', '3101295878', 'Sistemas de Computacion CONZULTEK de Centroamerica S.A', NULL, 'gguillen@masterzon.com', '506 22216300', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-31', 'WEB', NULL),
('rcastillo', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 12:52:34', '2019-05-10', 'Roberto', 'Castillo', 'Araya', '110130981', 4, 'A', '3102534789', 'LATIN AMERICAN CAPITAL S.R.L', NULL, 'gguillen@masterzon.com', '88331367', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-09', 'Jose Rivas', '3101727041'),
('rchavarria', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-13 08:52:22', '2018-11-22', 'Roberto ', 'Chavarria', 'Perez', '108840454', 5, 'A', '3002662958', 'ASEMOPT', NULL, 'gguillen@masterzon.com', '72223821', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-27', 'Francisco Ulate Azofeifa', '206440727'),
('rmontero', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-07-17 10:56:16', '2019-02-28', 'RONNY', 'MONTERO', 'ALVARADO', '108100917', 4, 'A', '3102372096', 'promedical', NULL, 'gguillen@masterzon.com', '87777772', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-03-12', 'Francisco Ulate Azofeifa', '3101727041'),
('rrudin ', '$2y$10$tq4xAe.cCgKvTLX7g2as1OpNHtkP5qFtGxz8cxxUO5r', '$2y$10$tq4xAe.cCgKvTLX7g2as1OpNHtkP5qFtGxz8cxxUO5rDevmVhRsWC', NULL, '2019-06-23', 'Ricardo ', 'Rudin ', 'Mathieu', '109230768', 1, 'P', '3101714776', 'Princesadulce s.a', NULL, 'gguillen@masterzon.com', '71051788', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-23', 'WEB', NULL),
('rsojo', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 12:44:30', '2018-10-17', 'RODOLFO', 'SOJO', 'GUEVARA', '108090970', 5, 'A', '3101376814', 'ADC MOVIL', NULL, 'gguillen@masterzon.com', '8920-4040', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-10-18', 'Francisco Ulate Azofeifa', '206440727'),
('rsolis', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 12:31:09', '2018-10-11', 'Rodolfo de la Trinidad', 'Soli­s', 'Herrera', '106900999', 5, 'A', '106900999', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '89800809', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-10-11', 'Gerson', '801070063'),
('rvillalobos', '$2y$10$lI5Esdp8BPbi15sJrLwywO/YqbNQuVC6/LGoCpu8xfZ/sFycQ5wA2', '$2y$10$lI5Esdp8BPbi15sJrLwywO/YqbNQuVC6/LGoCpu8xfZ/sFycQ5wA2', '2018-11-07 23:20:06', '2019-05-10', 'Rafael ', 'Villalobos', 'Azofeifa', '401600419', 6, 'A', '3101727041', 'Masterzon', NULL, 'gguillen@masterzon.com', '', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-03-09', 'Rafael Villalobos', '3101727041'),
('rvillalobos 458', 'TMP3515', '', NULL, '2018-06-15', 'Rocio ', 'Villalobos ', 'Cabezas', '108010353', 1, 'P', '3101681623', 'Aap Negocios en la Nube S.A', NULL, 'gguillen@masterzon.com', '70118302', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-06-15', 'WEB', NULL),
('saguiar', '1305Lsjc', '$2y$10$h0xe7gxzuMX96px.nMIwleFVQzzlzs8iZQn4lFMyj.BqiMZYGAOFm', NULL, '2018-09-07', 'Ana Laura', 'Suarez', 'Aguiar', '110680863', 1, 'I', '110680863', 'Ana Laura', NULL, 'gguillen@masterzon.com', '89966223', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-03-14', 'Francisco Ulate Azofeifa', '3101727041'),
('schaverri', '$2y$10$.Ls8tGEJ8jConB5v26XiU.XOmblgDjvwgXnifVSZsXQ', '$2y$10$.Ls8tGEJ8jConB5v26XiU.XOmblgDjvwgXnifVSZsXQh/ZBvUy5k.', '2018-05-19 12:57:46', '2019-03-22', 'Sergio ', 'Chaverri', 'Cerdas', '111070740', 6, 'A', '3101595167', 'Signature South Consulting Costa Rica S.A.', NULL, 'gguillen@masterzon.com', '22881122', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-03-22', 'Francisco Ulate Azofeifa', '3101727041'),
('scolino', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-07-02 14:27:14', '2019-01-19', 'Soraya', 'Colino', 'Jimenez', 'AAB486058', 4, 'A', '3012682635', 'STEREOCARTO SL', NULL, 'gguillen@masterzon.com', '84680631', '', 'N', 'N', 'S', 'S', '0.00', 365, 0, 0, 'N', 0, '2018-01-22', 'Francisco Ulate Azofeifa', '3101727041'),
('sherrera', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-23 08:38:34', '2019-02-28', 'STEPHANNIE', 'HERRERA', 'FERRETO', '603820182', 5, 'A', '3002204388', 'AsoSYKES', NULL, 'gguillen@masterzon.com', '89033693', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-02-28', 'Francisco Ulate Azofeifa', '3101727041'),
('sobando', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-07-21 08:24:39', '2019-04-04', 'Stephany ', 'Obando', 'Sanchez', '304790697', 4, 'A', '3101225198', 'Constructora Contek S.A.', NULL, 'gguillen@masterzon.com', '84563728', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-04-04', 'Jose Rivas', '206440727'),
('srodriguez', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:12:41', '2019-05-10', 'SONIA', 'RODRIGUEZ', 'PEREZ', '1950826', 4, 'A', '3101127663', 'Creaciones Publicitarias Inter S.A', NULL, 'gguillen@masterzon.com', '83099636', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-03-13', 'Jose Rivas', '3101727041'),
('ssirias ', 'TMP83403', '', NULL, '2018-01-03', 'Steven ', 'Sirias ', 'Barrera', '111800946', 1, 'P', '3101637657', 'Constructora Revac', NULL, 'gguillen@masterzon.com', '87298591', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-01-03', 'WEB', ''),
('svenegas', 'TMP80026', '', NULL, '2018-04-26', 'Sylvia', 'Venegas', 'AjÃº', '0107900782', 1, 'P', '0107900782', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '88302950', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-04-26', 'WEB', NULL),
('szoch', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:09:36', '2018-11-24', 'Sergio Jose', 'Zoch', 'Rojas', '108790230', 4, 'A', '3101036581', 'SEGURICENTRO SA', NULL, 'gguillen@masterzon.com', '60509823', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-05-03', 'Francisco Ulate Azofeifa', '206440727'),
('tarce', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', NULL, '2019-06-19', 'Tatiana', 'Arce', 'Gonzalez', '206490617', 5, 'A', '3002454356', 'ASEUNILEVER', NULL, 'gguillen@masterzon.com', '72090716', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-19', 'Francisco Ulate Azofeifa', '3101727041'),
('vangulo', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-07-12 13:33:03', '2018-11-22', 'Viria ', 'Angulo ', 'Ramirez ', '303600624', 4, 'A', '3101225198', 'Constructora Contek SA', NULL, 'gguillen@masterzon.com', '84551687', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-22', 'Francisco Ulate Azofeifa', '3101727041'),
('vbejarano', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-07-18 12:01:35', '2019-05-10', 'Victor', 'Bejarano', 'Cubero', '105480569', 5, 'A', '105480569', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '88958175', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-05-11', 'Gerson', '3101727041'),
('vgomez', 'TMP13616', '', NULL, '2018-02-16', 'Virginia Maria', 'Gomez', 'Gomez', '110530424', 1, 'P', '110530424', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '71032778', '', 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-02-22', 'Jose Rivas', ''),
('vlines', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 12:54:18', '2018-07-31', 'VICENTE', 'LINES', 'FOURNIER', '1830937', 4, 'A', '3101736419', 'CIARRE BROKERAGE AND AVISORY SOCIEDAD ANONIMA', NULL, 'gguillen@masterzon.com', '', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-07-31', 'Gerson', '3101727041'),
('vmontero', 'TMP2009', '', NULL, '2019-02-09', 'Victor', 'Montero', 'Cordero', '112840963', 1, 'P', '112830963', 'Micro Solutions Enterprises', NULL, 'gguillen@masterzon.com', '87137199', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-02-09', 'WEB', NULL),
('wcai', 'TMP23423', '', NULL, '2017-11-22', 'William', 'Cai', 'Zhang', '701900458', 1, 'P', '11578965432', 'Aurora', NULL, 'gguillen@masterzon.com', '62385326', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2016-11-22', 'WEB', ''),
('wchen', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '$2y$10$BE7QUteFaUdNPiQ9NyQTDe7nzIa6a/3iYbmS34/iKbVXi9OwKw2SO', '2018-05-19 12:52:18', '2017-08-09', 'William ', 'Chen', 'Mok', '602240460', 5, 'A', '602240460', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '88688084', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-11-17', 'Jose Rivas', '3101727041'),
('wchinchilla', '$2y$10$4dIAa8eZSbPfVYQHN7vb9OZx/J5xuBGLgmr4IN5Fe1I', '$2y$10$4dIAa8eZSbPfVYQHN7vb9OZx/J5xuBGLgmr4IN5Fe1I4DuDswIQsi', NULL, '2019-06-21', 'William', 'Chinchilla', 'Sanchez', '105110921', 1, 'P', 'U La Salle', 'William Chinchilla', NULL, 'gguillen@masterzon.com', '22347014', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-06-21', 'WEB', NULL),
('wmadrigal', '$2y$10$6yOdDfZoccS2OpJejQVBe.EG8BS/H5IyclVmWTYdZW7', '$2y$10$6yOdDfZoccS2OpJejQVBe.EG8BS/H5IyclVmWTYdZW7fykLShG36W', NULL, '2019-07-18', 'Wendy', 'Madrigal', 'Bolanos', '111460989', 1, 'P', '111460989', 'Cuenta de persona fisica.', NULL, 'gguillen@masterzon.com', '83289262', NULL, 'N', 'N', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2018-07-18', 'WEB', NULL),
('wvillalobos', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '$2y$10$Wjb77q48sC6JESKpPj6XyOCzAmMy16k8cbhittp2egM.ujlaBoSKe', '2018-05-19 13:11:00', '2019-05-10', 'Willy', 'Villalobos', 'Villalobos', '401420331', 4, 'A', '3101098063', 'Mutiasa', NULL, 'gguillen@masterzon.com', '89108197', '', 'N', 'S', 'S', 'N', '0.00', 365, 0, 0, 'N', 0, '2017-07-10', 'Jose Rivas', '3101727041');

-- --------------------------------------------------------

--
-- Table structure for table `sis_variables_secciones`
--

CREATE TABLE `sis_variables_secciones` (
  `cod_contrato` int(11) NOT NULL,
  `cod_seccion` int(11) NOT NULL,
  `cod_variable` varchar(50) NOT NULL,
  `des_query_dato` varchar(1000) DEFAULT NULL,
  `des_fuente_texto` varchar(100) DEFAULT 'Arial',
  `des_tamano_texto` int(11) DEFAULT '11',
  `ind_negrita` char(1) DEFAULT 'S',
  `ind_cursiva` char(1) DEFAULT 'N',
  `ind_italica` char(1) DEFAULT 'N',
  `ind_subrayado` char(1) DEFAULT 'N',
  `usr_modificacion` varchar(50) NOT NULL,
  `fec_modificacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sis_variables_secciones`
--

INSERT INTO `sis_variables_secciones` (`cod_contrato`, `cod_seccion`, `cod_variable`, `des_query_dato`, `des_fuente_texto`, `des_tamano_texto`, `ind_negrita`, `ind_cursiva`, `ind_italica`, `ind_subrayado`, `usr_modificacion`, `fec_modificacion`) VALUES
(1, 2, 'NOP', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` ) VALUES (CED_CLIENTE,NUM_OPERACION, 2, \'NOP\', (SELECT abs(NUM_OPERACION)))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2017-05-25 10:11:24'),
(1, 3, 'CDA', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\nVALUES\n(CED_CLIENTE,NUM_OPERACION,3 ,\'CDA\' , (SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS017\'))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 12:18:24'),
(1, 3, 'CJR', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\r VALUES\r (CED_CLIENTE,NUM_OPERACION, 3,\'CJR\' , (SELECT num_identificacion FROM sis_catalogo_juridicos where num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 10:17:34'),
(1, 3, 'CRA', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\nVALUES\n(CED_CLIENTE,NUM_OPERACION, 3, \'CRA\', (SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS024\'))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 12:17:01'),
(1, 3, 'CRL', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\nVALUES\n(CED_CLIENTE,NUM_OPERACION, 3, \'CRL\', (SELECT num_cedula_rep_legal FROM sis_catalogo_juridicos where num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 10:28:01'),
(1, 3, 'DRL', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\nVALUES\n(CED_CLIENTE,NUM_OPERACION, 3, \'DRL\', (SELECT des_direccion_rep_legal FROM sis_catalogo_juridicos where num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 10:26:02'),
(1, 3, 'ECR', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\nVALUES\n(CED_CLIENTE,NUM_OPERACION, 3, \'ECR\', (SELECT E.des_estado_civil FROM sis_catalogo_juridicos J INNER JOIN sis_estado_civil E ON E.cod_estado_civil = J.cod_estado_civil_rep_legal WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 12:02:15'),
(1, 3, 'FEC', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` ) VALUES (CED_CLIENTE,NUM_OPERACION, 3, \'FEC\', (SELECT concat(date_format(now(),\'%d\'),\' de \',date_format(NOW(),\'%b\'),\' del \',date_format(NOW(),\'%Y\'))))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2017-05-25 10:11:24'),
(1, 3, 'NRL', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\nVALUES\n(CED_CLIENTE,NUM_OPERACION, 3, \'NRL\', (SELECT des_nombre_rep_legal FROM sis_catalogo_juridicos WHERE num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 10:24:41'),
(1, 3, 'PRL', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\n VALUES\n (CED_CLIENTE,NUM_OPERACION, 3,\'PRL\', (SELECT des_profesion_rep_legal FROM sis_catalogo_juridicos WHERE num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 12:11:17'),
(1, 3, 'RLA', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\nVALUES\n(CED_CLIENTE,NUM_OPERACION, 3, \'RLA\', (SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS016\'))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 12:13:10'),
(1, 3, 'RSC', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\nVALUES\n(CED_CLIENTE,NUM_OPERACION, 3, \'RSC\', (SELECT des_razon_social FROM sis_catalogo_juridicos where num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 11:02:49'),
(1, 15, 'ABC', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\r\n VALUES\r\n (CED_CLIENTE,NUM_OPERACION,15 , \'ABC\', (SELECT ifnull(des_aux_tipo,\'\') FROM sis_catalogo_juridicos WHERE num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-06-28 15:04:03'),
(1, 15, 'CDO', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\n VALUES\n (CED_CLIENTE,NUM_OPERACION,15 , \'CDO\', (SELECT cod_deudor FROM sis_operaciones where num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 11:00:57'),
(1, 15, 'DDO', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\n VALUES\n (CED_CLIENTE,NUM_OPERACION,15 , \'DDO\', (SELECT J.des_razon_social FROM sis_operaciones O INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_deudor where O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 11:05:48'),
(1, 15, 'FFO', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\n VALUES\n (CED_CLIENTE,NUM_OPERACION,15 ,\'FFO\', (SELECT DATE_FORMAT(fec_emision,\'%d %b %Y\') FROM sis_operaciones where num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 10:56:47'),
(1, 15, 'MFO', 'INSERT INTO `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\r   VALUES (CED_CLIENTE,NUM_OPERACION,15 , \'MFO\', (SELECT fORMAT(sum(mon_facial),2) FROM sis_operaciones  WHERE num_documento = (select num_documento from sis_operaciones where num_operacion = NUM_OPERACION)\r  AND cod_vendedor = (select cod_vendedor from sis_operaciones where num_operacion = NUM_OPERACION)\r  AND cod_deudor = (select cod_deudor from sis_operaciones where num_operacion = NUM_OPERACION)\r  AND fec_estimada_pago = (select fec_estimada_pago from sis_operaciones where num_operacion = NUM_OPERACION)\r  and cod_estado not in (7,10,1)))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 11:07:44'),
(1, 15, 'MOP', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\n VALUES\n (CED_CLIENTE,NUM_OPERACION,15,\'MOP\' , (SELECT J.des_nombre FROM sis_operaciones O INNER JOIN sis_tipos_monedas J ON J.cod_tipo_moneda = O.cod_tipo_moneda where O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 11:10:04'),
(1, 15, 'NDO', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\n VALUES\n (CED_CLIENTE,NUM_OPERACION,15 ,\'NDO\' , (SELECT num_documento FROM sis_operaciones where num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 10:58:21'),
(1, 15, 'XYZ', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )\r\n VALUES\r\n (CED_CLIENTE,NUM_OPERACION,15 , \'XYZ\', (SELECT ifnull(des_aux_valor,\'\') FROM sis_catalogo_juridicos WHERE num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-06-28 15:06:27'),
(1, 18, 'CCA', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )  VALUES  (CED_CLIENTE,NUM_OPERACION,18, \'CCA\', (SELECT  ifnull(J.num_cc_colones_ATA,( SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS022\')) AS CTA_COL  FROM sis_operaciones O INNER JOIN sis_catalogo_juridicos J ON O.cod_deudor = J.num_identificacion WHERE O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 11:53:00'),
(1, 18, 'CDA', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )  VALUES (CED_CLIENTE,NUM_OPERACION,18, \'CDA\', (SELECT  ifnull(J.num_cc_dolares_ATA,(SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS019\')) AS CC_DOL FROM sis_operaciones O INNER JOIN sis_catalogo_juridicos J ON O.cod_deudor = J.num_identificacion WHERE O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-06-28 15:07:24'),
(1, 18, 'CSA', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` ) VALUES (CED_CLIENTE,NUM_OPERACION,18 , \'CSA\',(SELECT  ifnull(J.num_cta_colones_ATA,( SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS021\')) AS CTA_COL  FROM sis_operaciones O INNER JOIN sis_catalogo_juridicos J ON O.cod_deudor = J.num_identificacion WHERE O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-06-28 15:12:46'),
(1, 18, 'DSA', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )  VALUES  (CED_CLIENTE,NUM_OPERACION,18 , \'DSA\', (SELECT  ifnull(J.num_cta_dolares_ATA,(SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS018\')) AS CTA_DOL FROM sis_operaciones O INNER JOIN sis_catalogo_juridicos J ON O.cod_deudor = J.num_identificacion WHERE O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-06-28 15:13:50'),
(1, 18, 'ICA', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` )  VALUES (CED_CLIENTE,NUM_OPERACION,18 , \'ICA\',(SELECT  ifnull(J.num_iban_colones_ATA,(SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS023\')) AS IBN_COL  FROM sis_operaciones O INNER JOIN sis_catalogo_juridicos J ON O.cod_deudor = J.num_identificacion WHERE O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-06-29 08:32:11'),
(1, 18, 'IDA', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` ) VALUES (CED_CLIENTE,NUM_OPERACION,18 , \'IDA\',(SELECT  ifnull(J.num_iban_dolares_ATA,(SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS020\')) AS IBN_DOL FROM sis_operaciones O INNER JOIN sis_catalogo_juridicos J ON O.cod_deudor = J.num_identificacion WHERE O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2017-05-25 11:15:54'),
(1, 22, 'NRL', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` ) VALUES (CED_CLIENTE,NUM_OPERACION,22, \'NRL\', (SELECT des_nombre_rep_legal FROM sis_catalogo_juridicos where num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2017-05-25 10:11:24'),
(1, 22, 'RLA', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` ) VALUES (CED_CLIENTE,NUM_OPERACION, 22, \'RLA\', (SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS016\'))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2017-05-25 10:11:24'),
(1, 22, 'RSC', 'INSERT INTO  `sis_datos_tmp_contratos` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable` ) VALUES (CED_CLIENTE,NUM_OPERACION,22, \'RSC\', (SELECT des_razon_social FROM sis_catalogo_juridicos where num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2017-05-25 10:11:24'),
(2, 1, 'ENC', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,1, \'ENC\', (SELECT \'No necesario\' from dual))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2018-02-02 17:06:24'),
(2, 2, 'NOP', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,2, \'NOP\', (SELECT num_operacion FROM sis_operaciones where num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 2, 'YYY', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,2, \'YYY\', (SELECT year(now())))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 3, 'MDA', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,3, \'MDA\', (SELECT CASE WHEN O.ind_operacion_liquidada = \'S\' and O.cod_tipo_moneda = 1 then \'US$\'\nELSE CASE WHEN O.ind_operacion_liquidada = \'N\' AND O.cod_tipo_moneda = 2 then \'US$\' ELSE \'CRC\' END\nEND as moneda from  sis_operaciones O INNER JOIN sis_tipos_monedas M on M.cod_tipo_moneda = O.cod_tipo_moneda where O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 3, 'MTO', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,3, \'MTO\', (SELECT format(O.mon_transado,2) from sis_operaciones O  where O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 4, 'CED', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'CED\', (SELECT CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 4, 'CRL', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'CRL\', (SELECT J.num_cedula_rep_legal FROM sis_catalogo_juridicos J WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'new', '2018-02-05 15:37:48'),
(2, 4, 'CTE', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'CTE\', (SELECT J.des_razon_social FROM sis_catalogo_juridicos J WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 4, 'DDD', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'DDD\', (SELECT day(O.fec_liquidacion) from sis_operaciones O  where O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 4, 'DIR', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'DIR\', (SELECT J.des_direccion_rep_legal FROM sis_catalogo_juridicos J WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'new', '2018-02-05 15:33:44'),
(2, 4, 'ECR', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'ECR\', (SELECT C.des_estado_civil FROM sis_catalogo_juridicos J INNER JOIN sis_estado_civil C ON C.cod_estado_civil = J.cod_estado_civil_rep_legal WHERE J.num_identificacion = CED_CLIENTE))\n', 'Arial', 11, 'S', 'N', 'N', 'N', 'new', '2018-02-05 15:07:42'),
(2, 4, 'MDA', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'MDA\', (SELECT CASE WHEN O.ind_operacion_liquidada = \'S\' and O.cod_tipo_moneda = 1 then \'US$\'\nELSE CASE WHEN O.ind_operacion_liquidada = \'N\' AND O.cod_tipo_moneda = 2 then \'US$\' ELSE \'CRC\' END\nEND as moneda from  sis_operaciones O INNER JOIN sis_tipos_monedas M on M.cod_tipo_moneda = O.cod_tipo_moneda where O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 4, 'MMM', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'MMM\', (SELECT MESES_EN_ESPANOL(DATE_FORMAT(O.fec_liquidacion, \"%M\")) AS MES  from sis_operaciones O  where O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 4, 'MTO', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'MTO\', (SELECT FORMAT(O.mon_transado,2) from sis_operaciones O  where O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 4, 'PRF', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'PRF\', (SELECT J.des_profesion_rep_legal FROM sis_catalogo_juridicos J WHERE J.num_identificacion = CED_CLIENTE))\n', 'Arial', 11, 'S', 'N', 'N', 'N', 'new', '2018-02-05 15:32:01'),
(2, 4, 'RND', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'RND\', (SELECT O.num_rendimiento from sis_operaciones O  where O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 4, 'RSC', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'RSC\', (SELECT J.des_nombre_rep_legal FROM sis_catalogo_juridicos J WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'new', '2018-02-05 15:02:06'),
(2, 4, 'S21', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'S21\',  (SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS021\'))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2018-02-02 14:49:13'),
(2, 4, 'S22', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'S22\',  (SELECT val_parametro FROM sis_parametros where cod_parametro = \'SIS022\'))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2018-02-02 14:51:07'),
(2, 4, 'YYY', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,4, \'YYY\', (SELECT YEAR(O.fec_liquidacion) from sis_operaciones O  where O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'S', 'dba', '2018-02-01 10:11:24'),
(2, 5, 'XXX', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,5, \'XXX\', (SELECT \'No necesario\' from dual))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2018-02-02 16:58:21'),
(2, 6, 'DDD', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,6, \'DDD\', (SELECT DAY(now())))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2018-02-02 15:07:47'),
(2, 6, 'DIA', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,6, \'DIA\', (SELECT DIAS_EN_ESPANOL(DATE_FORMAT(NOW(), \"%W\"))))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2018-02-02 15:06:09'),
(2, 6, 'MMM', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,6, \'MMM\', (SELECT MESES_EN_ESPANOL(DATE_FORMAT(now(), \"%M\"))))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2018-02-02 15:09:11'),
(2, 6, 'YYY', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,6, \'YYY\', (SELECT YEAR(now())))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2018-02-02 15:09:51'),
(2, 7, 'CED', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,7, \'CED\', (SELECT J.num_cedula_rep_legal FROM sis_catalogo_juridicos J WHERE J.num_identificacion = CED_CLIENTE))\n', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2018-02-02 15:16:42'),
(2, 7, 'CTE', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,7, \'CTE\', (SELECT J.des_razon_social FROM sis_catalogo_juridicos J WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2018-02-02 15:11:08'),
(2, 7, 'RLG', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,7, \'RLG\', (SELECT J.des_nombre_rep_legal FROM sis_catalogo_juridicos J WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-05 16:01:58'),
(2, 7, 'RSC', 'INSERT INTO  `sis_datos_tmp_letras_cambio` (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION,7, \'RSC\', (SELECT J.des_nombre_rep_legal FROM sis_catalogo_juridicos J WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', 'dba', '2018-02-02 15:14:32'),
(3, 1, 'DRP', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,1, \'DRP\', (SELECT J.des_direccion_contacto    FROM sis_catalogo_juridicos J  WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:05:00'),
(3, 1, 'EMP', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,1, \'EMP\', (SELECT CONCAT(\'Ced:\',\' / \',J.num_identificacion) AS num_identificacion FROM sis_catalogo_juridicos J  WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:05:00'),
(3, 1, 'ICO', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,1, \'ICO\', (SELECT J.des_logo_cliente FROM sis_catalogo_juridicos J  WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:06:02'),
(3, 1, 'RSP', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,1, \'RSP\', (SELECT J.des_razon_social FROM sis_catalogo_juridicos J  WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:06:02'),
(3, 1, 'TLP', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,1, \'TLP\', (SELECT J.des_telefono_contacto  FROM sis_catalogo_juridicos J  WHERE J.num_identificacion = CED_CLIENTE))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:06:39'),
(3, 2, 'DCT', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,2, \'DCT\', ( SELECT upper(num_documento) FROM sis_operaciones WHERE num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:06:39'),
(3, 2, 'DRV', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,2, \'DRV\', (SELECT J.des_direccion_contacto  FROM sis_operaciones O INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_deudor WHERE O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:07:21'),
(3, 2, 'EMV', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,2, \'EMV\', (SELECT concat(\'Ced:\',\'/ \',J.num_identificacion) as num_identificacion  FROM sis_operaciones O INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_deudor WHERE O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:07:21'),
(3, 2, 'FEM', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,2, \'FEM\', ( SELECT fec_emision  FROM sis_operaciones WHERE num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:07:56'),
(3, 2, 'FEP', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,2, \'FEP\', ( SELECT fec_estimada_pago FROM sis_operaciones WHERE num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:07:56'),
(3, 2, 'RLV', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,2, \'RLV\', (SELECT J.des_razon_social   FROM sis_operaciones O INNER JOIN sis_catalogo_juridicos J ON J.num_identificacion = O.cod_deudor WHERE O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:08:27'),
(3, 3, 'CFC', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,3, \'CFC\', (SELECT FRACCIONES))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-22 15:06:08'),
(3, 3, 'FCL', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,3, \'FCL\', (select format(mon_facial,2) as mon_facial from sis_operaciones WHERE num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:08:27'),
(3, 3, 'FLT', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,3, \'FLT\', (select format(mon_facial * FRACCIONES,2) as mon_facial from sis_operaciones WHERE num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-22 15:05:09'),
(3, 3, 'MDA', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,3, \'MDA\', (SELECT M.des_tipo_moneda FROM sis_operaciones O INNER JOIN sis_tipos_monedas M ON M.cod_tipo_moneda = O.cod_tipo_moneda WHERE O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:09:19'),
(3, 3, 'TPO', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,3, \'TPO\', (SELECT T.des_tipo_factura FROM sis_operaciones O INNER JOIN sis_tipos_facturas T ON T.cod_tipo_factura = O.cod_tipo_factura WHERE O.num_operacion = NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:09:19'),
(3, 4, 'PLZ', 'INSERT INTO  sis_datos_tmp_factura_estandar (`num_identificacion`,`num_operacion`,`can_fracciones`,`cod_seccion`,`cod_variable`,`des_valor_variable`) VALUES (CED_CLIENTE,NUM_OPERACION, FRACCIONES,4, \'PLZ\', (SELECT cod_tipo_plazo FROM sis_operaciones WHERE num_operacion =  NUM_OPERACION))', 'Arial', 11, 'S', 'N', 'N', 'N', '', '2018-02-21 15:09:45');

-- --------------------------------------------------------

--
-- Table structure for table `TABLE 37`
--

CREATE TABLE `TABLE 37` (
  `COL 1` varchar(1428) DEFAULT NULL,
  `COL 2` varchar(30) DEFAULT NULL,
  `COL 3` varchar(6) DEFAULT NULL,
  `COL 4` varchar(32) DEFAULT NULL,
  `COL 5` varchar(8) DEFAULT NULL,
  `COL 6` varchar(257) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `TABLE 37`
--

INSERT INTO `TABLE 37` (`COL 1`, `COL 2`, `COL 3`, `COL 4`, `COL 5`, `COL 6`) VALUES
('num_identificacion;cod_tipo_identificacion;des_razon_social;des_nick_name;cod_nacionalidad;fec_constitucion;num_score;cod_ejecutivo;cod_ejecutivo_backup;cod_tipo_membresia;num_cuenta_dolares;num_cuenta_colones;num_cuenta_euros;num_cta_colones_ATA;num_cta_dolares_ATA;num_cc_colones_ATA;num_cc_dolares_ATA;num_iban_colones_ATA;num_iban_dolares_ATA;num_cedula_rep_legal;des_nombre_rep_legal;des_direccion_rep_legal;cod_estado_civil_rep_legal;des_profesion_rep_legal;des_nombre_contacto;des_telefono_contacto;des_correo_contacto;des_direccion_contacto;cod_actividad_economica;ind_tipo_cliente;ind_es_fideicomiso;ind_tipo_representante_legal;cod_pais;cod_provincia;cod_canton;cod_distrito;cod_tipo_sector;mon_riesgo_inherente;des_logo_cliente;des_descripcion;des_aux_tipo;des_aux_valor;fec_creacion;cod_usuario_modificacion', NULL, NULL, NULL, NULL, NULL),
('104131393;1;MANUEL ENRIQUE ARGUEDAS VENEGAS;ENRIQUE ARGUEDAS;CR;2018-10-14;1;3101727041;\";2;\";\";\";\";\";\";\";\";\";104131393;\";\";1;\";\";\";\";\";0;N;N;\";\";0;0;0;0;0.0;\";\";\";\";2018-06-01 16:03:35;Gerson', NULL, NULL, NULL, NULL, NULL),
('105480569;1;Victor Bejarano;Victor Bejarano;CR;2017-04-19;1;2147483647;\";2;\";15100010011922440;\";\";\";\";\";\";\";\";\";\";2;\";\";88958175;vibecu@hotmail.com;\";0;N;N;\";1;1;1;1;1;1.0;\";\";\";\";2017-05-11 18:36:19;Gerson', NULL, NULL, NULL, NULL, NULL),
('106900999;1;Rodolfo de la Trinidad Solis Herrera;Cuenta de persona fisica.;cr;2017-10-11;1;1;0;10;0;0;0;\";\";\";\";\";\";106900999;Rodolfo de la Trinidad;N/R;1;0;N/R;Rodolfo de la Trinidad;presidencia@ransa.co.cr;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-10-11 09:30:09;WEB', NULL, NULL, NULL, NULL, NULL),
('108850253;1;MARIO JOSE RAMIREZ AGUILAR;Mario Ramirez;cr;2017-10-10;1;2147483647;0;2;0; 15104420010063381;0;\";\";\";\";\";\";108850253;Mario José Ramírez Aguilar;San Joaquín de Flores, Heredia;4;Ingeniero Agrónomo;Mario José Ramírez Aguilar;83993622;mariorram@yahoo.com;San Joaquín de Flores, Heredia;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-11-30 20:53:02;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('109120257;1;Jairo Solano Monge;Jairo Solano Monge;cr;2017-11-14;1;1;0;10;0;0;0;\";\";\";\";\";\";109120257;Jairo;N/R;1;0;N/R;Jairo;jairosm@gmail.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-11-14 15:52:00;WEB', NULL, NULL, NULL, NULL, NULL),
('109260511;1;ELIO ROJAS ROJAS;ELIO;crc;2016-10-04;0;109260511;\";8;10200009240919780;10200009216794112;\";\";\";\";\";\";\";0;n/r;n/r;1;0;\";\";eliorojas7@gmail.com;\";0;N;\";\";\";0;0;0;0;0.0;\";\";\";\";2018-05-21 16:50:07;Gerson', NULL, NULL, NULL, NULL, NULL),
('109460803;1;Rodolfo Carrillo Mena;Rodolfo Carrillo Mena;cr;2017-10-12;1;2147483647;0;10;0;0;0;\";\";\";\";\";\";109460803;Rodolfo;N/R;1;0;N/R;Rodolfo;rjcarrillo@hotmail.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-10-13 00:55:52;Gerson', NULL, NULL, NULL, NULL, NULL),
('109470074;1;Cuenta de persona fisica.;Cuenta de persona fisica.;cr;2017-11-20;1;1;0;0;0;0;0;\";\";\";\";\";\";109470074;Andres;N/R;1;0;N/R;Andres;drobandov@gmail.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-11-20 05:47:09;WEB', NULL, NULL, NULL, NULL, NULL),
('109500718;1;Cuenta de persona fisica.;Manfred Aguero D.;cr;2017-12-13;1;801070063;0;2;0;81400011007766040;0;\";\";\";\";\";\";109500718;Manfed;San Jose, Mora, Guayabo, 25 metros norte de la Escuela Adela Rodriguez;1;Administrador;Manfred Aguero D.;87206108;managuero@outlook.com;San Jose, Mora, Guayabo, 25 metros norte de la Escuela Adela Rodriguez;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-12-13 17:22:36;Gerson', NULL, NULL, NULL, NULL, NULL),
('110110991;1;EDGAR OVIEDO BLANCO;EDGAR OVIEDO BLANCO;cr;2017-11-02;1;1;0;10;0;0;0;\";\";\";\";\";\";110110991;EDGAR;N/R;1;0;N/R;EDGAR;edgar.oviedo@gmail.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-11-02 09:56:10;WEB', NULL, NULL, NULL, NULL, NULL),
('110310902;1;Carmelo Enrique Solis Jimenez;Carmelo Enrique Solis Jimenez;cr;2017-11-20;1;1;0;10;0;0;0;\";\";\";\";\";\";110310902;Carmelo Enrique;N/R;1;0;N/R;Carmelo Enrique;solise153@gmail.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-11-20 14:16:57;WEB', NULL, NULL, NULL, NULL, NULL),
('110530424;1;Virginia María Gómez Gómez;Ejecutiva;CR;2017-02-16;1;110530424;\";2;\";\";\";\";\";\";\";\";\";110530424;\";\";1;\";\";\";asesoria.financieracr@outlook.es;\";0;N;\";\";\";0;0;0;0;0.0;\";\";\";\";2017-02-16 20:17:47;Gerson', NULL, NULL, NULL, NULL, NULL),
('11058037;1;Esteban Vargas Gomez;Esteban Vargas;CR;2017-03-07;1;1;\";2;15202001162677374;15202942000070051;\";\";\";\";\";\";\";\";\";\";2;Dentista, Costarricense, ;Esteban Vargas Gomez;88249590;esvarg@gmail.com;\";0;N;\";\";\";0;0;0;0;0.0;\";\";\";\";2017-03-07 17:32:36;Gerson', NULL, NULL, NULL, NULL, NULL),
('110610737;1;Cuenta de persona fisica.;Cuenta de persona fisica.;cr;2017-12-26;1;1;0;0;0;0;0;\";\";\";\";\";\";110610737;Manuel;N/R;1;0;N/R;Manuel;manuelalbertomoral@hotmail.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-12-26 23:19:54;WEB', NULL, NULL, NULL, NULL, NULL),
('110680863;1;Ana Laura;Ana Laura;cr;2017-09-07;1;2147483647;0;8;15108420020087409;11400007316066796;0;\";\";\";\";\";\";110680863;Ana Laura;Santa Ana, Pozos ;2;Relaciones Publicas ;N/R;0;analaurasuarez@me.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-09-07 22:19:40;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('111460989;1;Cuenta de persona fisica.;Cuenta de persona fisica.;cr;2018-07-18;1;1;0;0;0;0;0;\";\";\";\";\";\";111460989;Wendy;N/R;1;0;N/R;Wendy;wmadrigal@gmail.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-07-18 08:48:53;WEB', NULL, NULL, NULL, NULL, NULL),
('112830963;2;Micro Solutions Enterprises;Micro Solutions Enterprises;CR;2018-02-09;1;1;0;0;0;0;0;\";\";\";\";\";\";112840963;Victor;N/R;1;0;N/R;Victor;msecostarica@gmail.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-02-09 06:17:09;WEB', NULL, NULL, NULL, NULL, NULL),
('113310539;1;Adrian Campos Oviedo;Adrian Campos Oviedo;cr;2017-10-12;1;801070063;0;10;0;0;0;\";\";\";\";\";\";113310539;Adrian;N/R;1;0;N/R;Adrian;flippercallcampos@yahoo.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-10-13 00:56:58;Gerson', NULL, NULL, NULL, NULL, NULL),
('115240900;1;Cuenta de persona fisica.;Cuenta de persona fisica.;cr;2017-11-14;1;1;0;0;0;0;0;\";\";\";\";\";\";115240900;Francisco;N/R;1;0;N/R;Francisco;fran.mocas@gmail.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-11-14 15:34:44;WEB', NULL, NULL, NULL, NULL, NULL),
('125000094724;1;Michel Satger;Michel Satger;\";2017-04-19;1;206440727;\";2;11400007415136682;81610300016153485;\";\";\";\";\";\";\";\";\";\";2;\";\";\";\";\";0;N;\";\";\";0;0;0;0;0.0;\";\";\";\";2017-09-22 22:00:49;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('152800006724;1;CORNELIA MARIA MAGDALENA BARTELS;Cora_Bartels;188;2016-12-01;1;109260511;\";2;CR29010200009323246277;CR68010200009323246351;\";\";\";\";\";\";\";152800006724;\";\";1;\";\";88428080;corabartels@hotmail.com;\";0;N;\";\";188;1;1;1;1;1.0;\";\";\";\";2018-05-04 22:05:16;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('206530872;1;Cuenta de persona fisica.;Cuenta de persona fisica.;cr;2018-02-11;1;1;0;0;0;0;0;\";\";\";\";\";\";206530872;JosÃ© Pablo;N/R;1;0;N/R;JosÃ© Pablo;rodriguezch.pablo@gmail.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-02-11 16:58:05;WEB', NULL, NULL, NULL, NULL, NULL),
('2100042000829;2;Ministerio de Obras Publicas y Transporte;MOPT;cr;1948-05-08;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;N;\";188;1;1;1;1;1.0;images/logo_mopt.png;En 1860 dada la importancia que iban adquiriendo los edificios pÃºblicos, caminos y demÃ¡s obras construidas por cuenta de los fondos nacionales o de las provincias, se considerÃ³ pertinente crear una instituciÃ³n con el objeto de que Ã©stas se construyeran bajo su responsabilidad y en consideraciÃ³n con las reglas del arte......... <a href=\'http://www.mopt.go.cr/wps/portal/Home/acercadelministerio/informaciondelmopt/!ut/p/z1/04_Sj9CPykssy0xPLMnMz0vMAfIjo8ziPQPcDQy9TQx83M2CXAwcLX18TN38DYwtwgz0w8EKDFCAo4FTkJGTsYGBu7-RfhTp-pFNIqw_Cq-SIDOoAnxOxKIAxQ0FuaERBpmeigAQwbes/dz/d5/L2dBISEvZ0FBIS9nQSEh/\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:35:29;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('2100042002;2;MINISTERIO DE EDUCACION PUBLICA;MEP;CR;1965-03-13;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/mep.png;La Ley No. 3481 establece la función del MEP de administrar todos los elementos que lo integran, para la ejecución de las disposiciones pertinentes del Título Sétimo de la Constitución Política de la Ley Fundamental de Educación de las leyes conexas y de los respectivos reglamentos.... <a href=\'http://www.mep.go.cr/transparencia-institucional/informacion/ley-organica\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:35:52;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('2100042006;2;MINISTERIO DE JUSTICIA Y PAZ;MIN. JUSTICIA;CR;1870-08-20;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;N;\";188;1;1;1;1;1.0;images/MJP.png;La Constitucion Politica de 1847 creo el Ministerio de Relaciones Interiores, Exteriores, GobernaciÃ³n, Justicia y Negocios EclesiÃ¡sticos. Un aÃ±o despuÃ©s, se modificÃ³ esa ConstituciÃ³n y desaparece la nomenclatura de \"Justicia\". La cartera de Justicia fue constituida mediante decreto N.Â° 29 del 20 de junio de 1870, que creÃ³ el \"Reglamento de Gobierno y Atribuciones de la SecretarÃ­a de Estado\", firmado por ... <a href=\'http://www.mjp.go.cr/Acerca?nom=historia-institucional\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:36:13;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('2100042011;2;MINISTERIO DE SEGURIDAD PUBLICA;MSP;CRC;1973-12-24;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/MSP.png;1923: El presidente Julio Acosta elimina el Ministerio de Guerra,el cual fue reemplazado por el Ministerio de Seguridad Publica y las actividades militares pasaron a un segundo plano. El 13 de abril de ese mismo año, mediante la Ley numero 93, se creo la Direccion de Investigaciones Criminales<a href=\'http://www.seguridadpublica.go.cr/ministerio/documentos/historia_msp.pdf\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:36:30;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('2100045222;2;PATRONATO DE CONSTRUCCIONES, INSTALACIONES Y ADQUISICION DE BIENES;PATRONATO DE CONSTRUCCIONES;\";1971-05-08;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/2100045222.png;El Patronato de Construcciones, Instalaciones y Adquisición de Bienes (PCIAB) es un órgano adscrito al Ministerio de Justicia y Paz, creado en la Ley de la Dirección General de Adaptación Social No. 4762 del 8 de mayo de 1971; pertenece al Sector Justicia, su función principal es coadyuvar tanto en el desarrollo y mejoramiento de la infraestructura penitenciaria como de las condiciones de vida de las personas privadas de libertad.;\";\";2018-01-15 17:59:58;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('21651651;1;Cuenta de persona fisica.;Cuenta de persona fisica.;cr;2017-10-12;1;1;0;10;0;0;0;\";\";\";\";\";\";21651651;don;N/R;1;0;N/R;don;ron@damon.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-10-12 13:24:24;WEB', NULL, NULL, NULL, NULL, NULL),
('2300042155;2;CORTE SUPREMA DE JUSTICIA PODER JUDICIAL;CORTE SUPREMA;CR;1825-01-25;2;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/PJ.png;Con la Independencia de Costa Rica, el 15 de setiembre de 1821, los costarricenses se organizaron polÃ­ticamente y constituyeron un gobierno propio. Para el 1Â° de diciembre de 1821, los representantes de diferentes ciudades y pueblos de aquel entonces, formularon el Pacto Social Fundamental Interino de Costa Rica, conocido como el Pacto de Concordia, considerado como el primer documento constitucional de Costa Rica..... <a href=\'https://www.poder-judicial.go.cr/principal/index.php/informacion-institucional\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:36:49;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3002045433;2;ASOCIACION CRUZ ROJA COSTARRICENSE;CRUZ ROJA;\";1952-01-01;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;2;0.0;images/3002045433.jpg;Somos una Institución humanitaria de  carácter voluntario y de interés público,  con programas de atención de emergencias pre hospitalarias, respuesta a calamidades o desastres, promoción de la resiliencia comunitaria, el fomento de la no violencia y la cultura de paz, los cuales se desarrollan a través de 122 comités auxiliares (representaciones locales), 9 juntas regionales que integran para efectos administrativos y operativos a los comités auxiliares  y varias direcciones nacionales.;\";\";2018-05-30 22:37:08;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3002075697;2;Asociacion Solidarista de Empleados de Cía Galletas Pozuelo DCR, S.A. Asdepsa;ASDEPSA;cr;2017-10-06;1;206440727;0;2;0;10200009022937034	;0;\";\";\";\";\";\";108160212;Amalia Cavallo Aita;1.5 km al oeste del BAC San José, San Rafael, Escazú, San José;2;Ingeniera Industrial;Heidy María Bermúdez Flores;2299-1249;hmbermudez@pozuelo.cr;350 metros al norte del Puente Juan Pablo Segundo, La Uruca, San José;1;X;N;\";CR;1;1;1;1;0.0;images/ASDEPSA.jpg;\";\";\";2017-12-06 15:08:43;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3002078587;2;ASECEMEX;ASECEMEX;Costa Rica;2017-05-01;1;206440727;\";2;\";10200009016526367;\";\";\";\";\";\";\";502650080;JOSE ANGEL CORTEZ CRUZ;GUANACASTE;2;ADMINISTRACIÓN DE EMPRESA, Costarricense, ;\";\";carlosalberto.umanacastillo@ext.cemex.com;\";0;N;\";A;\";0;0;0;0;0.0;images/ASECEMEX.jpg;\";\";\";2018-03-01 17:20:25;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3002078847;2;ASOCIACIÓN SOLIDARISTA DERIVADOS DEL MAIZ ALIMENTICIO S.A;ASEDEMASA;\";2010-11-01;0;2147483647;\";2;\";15100010011642522;\";\";\";\";\";\";\";401650262;Randall Espinoza Romero;Mercedes Norte, Heredia, de la Capilla San Isidro 150 oeste y 50 norte;2;Ingeniero Industrial;Pamela Delgado Guadamuz;22311978;PDelgado@demasa.com;2 km oeste de la Embajada Americana, Pavas, San José;0;X;\";\";\";0;0;0;2;0.0;images/3002078847.png;Somos una Asociación Solidarista que procura la justicia, la paz social y la armonía obrero patronal, para el desarrollo integral de los asociados y sus familias, mediante el fomento del ahorro y la administración eficiente de los recursos, somos trabajadores de la empresa Derivados del Maíz S.A, la cual pertenece al Grupo Maseca.;\";\";2018-05-18 22:00:31;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3002152430;2;ASEHNN;ASEHNN;cr;2017-12-15;1;1;0;0;0;0;0;\";\";\";\";\";\";111180313;Graciela;N/R;1;0;N/R;Graciela;gzamora.asehnn@gmail.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-12-15 07:57:52;WEB', NULL, NULL, NULL, NULL, NULL),
('3002204388;2;ASOCIACION SOLIDARISTA DE EMPLEADOS DE SYKES LATIN AMERICA S.A;ASOSYKES;cr;1997-06-12;1;2147483647;0;2;0;44015201001024618894;0;\";\";\";\";\";\";113050328;Rebeca Guadamuz Ramirez;La Aurora de Heredia;1;Comunicadora;Stephanie Herrera Ferreto;89033693;STEPHANIE.HERRERA1@SYKES.COM;La Aurora de Heredia;1;X;N;\";CR;1;1;1;2;0.0;images/ico_asoskyes.png;AsoSykes es una asociacion que busca darle un excelente servicio al empleado de Sykes y por lo cual dia a dia trabajamos para ser un reflejo claro del solidarismo.;\";\";2018-03-07 17:00:32;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3002396430;2;ASEBOSTON;ASEBOSTON;CR;2017-05-08;1;206440727;\";2;12300003031812010;12300003031812004;\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;N;N;\";\";0;0;0;0;0.0;images/ASEBOSTON.jpg;\";\";\";2018-01-05 17:38:44;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3002454356;2;ASOCIACION SOLIDARISTA DE EMPLEADOS DE UNILEVER CENTROAMERICA S.A;ASEUNILEVER;\";2015-04-03;0;3101727041;\";2;\";10200009092265814;\";\";\";\";\";\";\";206490617;Tatiana Arce Gonzalez;125 oeste del Colegio Maria Inmaculada, Grecia, Alajuela;2;Tecnóloga de alimentos;Gabriel Meléndez Montero;87074895;Gabriel.melendez@aseunilever.com;San Antonio deBelén;0;X;\";\";\";0;0;0;2;0.0;\";\";\";\";2018-06-19 20:17:41;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3002662958;2;ASOCIACIÓN SOLIDARISTA DE EMPLEADOS DEL MOPT;ASEMOPT;cr;2012-10-05;1;206440727;0;2;15201001041160111;15113710010016059;0;\";\";\";\";\";\";303750577;Adrián Rodríguez Hernández;Residencial Los Faroles, Curridabat, San José;2;Administrador de Empresas;Ana Priscilla Moreno;88244338;Priscilla.moreno@asemopt.com;Edificio MOPT, Plaza Víquez, San José;1;X;N;\";CR;1;1;1;1;0.0;\";Las intenciones y los esfuerzos por que en el MOPT existiera una Asociación Solidarista datan de los años 2000, cuando un grupo de compañeros sentían una necesidad imperante de contar con tan importante organización, en especial viendo el ejemplo de otros ministerios e incluso sus propios consejos que contaban con una. Pero no fue hasta el año 2012 que fue posible la constitución de esta empresa privada. En ese momento, por medio del DECRETO EJECUTIVO No 36313-MOPT se ordena al Consejo de Seguridad Vial (COSEVI) trasladar todas las plazas ocupadas por la Dirección General de la Policía de Tránsito, al Ministerio de Obras Públicas y Transportes. Este importante grupo de colaboradores contaban con asociación Solidarista en el COSEVI y esperaban no perder este beneficio al a ser trasladados de planilla. Fue así como el 5 de octubre 2012, se constituye la ASOCIACION SOLIDARISTA DE EMPLEADOS DEL MINISTERIO DE OBRAS PUBLICAS Y TRANSPORTES. Con 256 asociados, alcanzado a setiembre 2016, 1756 ;\";\";2018-05-08 16:27:12;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3002702894;1;ASOCIACIÓN SOLIDARISTA DE EMPLEADOS DE ASEBOSTON;ASOA;\";2015-07-01;0;2147483647;\";2;12300130009378010;12300130009378004;\";\";\";\";\";\";\";401240207;María Isabel Bolaños Murillo;150 este del Más X Menos de San Antonio de Belén, Heredia;2;Secretaria;Grettel Porras Solís;24368407;grettel.porras@bsci.com;Zona Franca Propark, contiguo a la Dos Pinos, Coyol de Alajuela;0;N;\";\";\";0;0;0;2;0.0;\";\";\";\";2018-05-21 21:42:55;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3004045002;2;COOPERATIVA DE PRODUCTORES DE LECHE DOS PINOS R L;DOS PINOS;\";1947-08-26;0;206440727;\";6;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";1;C;N;1;188;0;0;0;2;0.0;images/dos_pinos.JPG;La Cooperativa nació en el marco del movimiento cooperativo que promovió la Sección de Fomento a cooperativas agrícolas e industriales por medio del Banco Nacional de Costa Rica. En el umbral de la crisis política que concluyó con la Guerra Civil de 1948 y en un panorama de desorganización de los mismos productores de leche, la tarde del 26 de agosto de 1947 veinticinco lecheros acordaron reunirse en la sede de la Cámara de Agricultura y Agroindustria.... <a href=\'http://www.dospinos.com/userfiles/file/pdf/backup_RESENA_HISTORICA_PDF.pdf\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-10-20 17:05:58;Gerson', NULL, NULL, NULL, NULL, NULL),
('3004045027;2;COOPERATIVA DE AHORRO Y CREDITO ANDE No.1, RL;COOPEANDE 1;CR;2017-04-19;1;2147483647;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";1;C;N;1;188;1;1;1;1;1.0;\";\";\";\";2017-04-19 18:54:03;Gerson', NULL, NULL, NULL, NULL, NULL),
('3004045083;2;COOPERATIVA DE CAFICULTORES Y SERVICIOS MULTIPLES DE TARRAZU R.L;COOPETARRAZU;CR;1960-10-13;0;206440727;\";2;15201332000011630 ;15201332000004340 ;\";\";\";\";\";\";\";601310715;Carlos Vargas Leitón;Calle Arenillas, Guadalupe, Cartago;2;Administrador de Empresas;Jennifer Ulloa Jiménez;89816521;julloa@coopetarrazu.com;San José, Tarrazú, San Marcos, 1 km al sur del parque;1;C;N;1;188;0;0;0;2;0.0;/images/ico_tarrazu.png;COOPETARRAZÚ, Cooperativa de Caficultores y de Servicios Múltiples de Tarrazú RL es una cooperativa de pequeños cafetaleros que procesa y vende café producido en forma sostenible. COOPETARRAZÚ también gestiona supermercados, vende materiales agrícolas, financia cosechas y brinda asistencia técnica. COOPETARRAZÚ ha recibido varias certificaciones, entre ellas la certificación orgánica y la de comercio justo, gracias a sus mejores prácticas sociales y ambientales.  El café de COOPETARRAZÚ está considerado entre los mejores del mundo, gracias a su nivel de acidez favorable y a su sabor y cuerpo excelentes. Las marcas propias de café tostado y molido (Buen Día y El Marqués) gozan de fuertes ventas gracias a las campañas de mercadeo y distribución de COOPETARRAZÚ.  La cooperativa emprendió una serie de iniciativas ambientales, como por ejemplo la instalación de paneles solares.;\";\";2018-02-05 23:04:18;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3004045111;2;COOPERATIVA DE AHORRO Y CREDITO DE LOS SERVIDORES PUBLICOS R.L;COOPESERVIDORES R.L;CR;2018-01-08;1;1;0;2;15104710026001664;15104710010015055;0;\";\";\";\";\";\";108180660;Mario Alberto Campos Conejo;N/R;1;0;N/R;JESÃšS ;eon@gmail.com;N/R;1;C;N;1;188;1;1;1;1;0.0;\";\";\";\";2018-01-08 20:21:00;WEB', NULL, NULL, NULL, NULL, NULL),
('3004045117;2;COOPERATIVA DE ELECTRIFICACION RURAL DE SAN CARLOS R L;COOPELESCA;CR;2017-03-12;1;2147483647;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";1;C;N;1;188;0;0;0;0;0.0;\";\";\";\";2017-05-29 20:27:28;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3004045205;2;Cooperativa Nacional de Educadores;COOPENAE;CR;2017-06-01;1;801070063;\";2;15108010026013455;15100010010531186;\";\";\";\";\";\";\";602400141;Johnny Gutierrez Delgado;\";2;\";Johnny Gutierrez Delgado;22579060;maguero@coopenae.fi.cr;\";1;C;N;1;188;1;1;1;1;1.0;images/coopenae.png;\";\";\";2018-03-12 22:03:36;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3007042030;2;REGISTRO NACIONAL;REGISTRO ;CR;2017-06-01;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;N;\";188;1;1;1;1;1.0;images/registro.png;Los primeros intentos de publicidad registral encuentran su gÃ©nesis en una solicitud de las Cortes de Madrid de 1528, a partir de la cual se dicta una \"Real PragmÃ¡tica\" en 1539, la cual establecÃ­a que las ciudades o villas que fueran cabeza de jurisdicciÃ³n, debÃ­an llevar un libro identificado como Registro de Censos y Tributos, en los que se registran los contratos de censos e hipotecas.... <a href=\'http://www.registronacional.go.cr/Institucion/index.htm\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:37:44;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3007045551;2;CONSEJO TECNICO DE AVIACION CIVIL;AVIACION CIVIL;\";1973-05-14;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3007045551.gif;Es el ente encargado de planificar, regular y proveer los servicios de la aviación civil en Costa Rica de forma ágil y transparente para garantizar y promover una actividad aeronáutica ordenada, eficiente, respetuosa con el medio ambiente, de calidad y segura que garantice la satisfacción de los usuarios y los intereses de la sociedad.;\";\";2018-02-01 18:41:19;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3007071587;2;CORPORACION DE SERVICIOS MULTIPLES DEL MAGISTERIO NACIONAL;CORPORACION MAGISTERIO NACIONAL;\";1985-07-11;0;3101727041;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;2;0.0;images/3007071587.png;A traves de los años, el Magisterio Nacional ha logrado fundar varias Instituciones que hoy, ademas de ser un orgullo para los maestros, son un ejemplo para el pais, ya que se han convertido en empresas poderosas, con objetivos claramente definidos y cuya labor principal ha estado enfocada a una funcion eminentemente social.  De ahi nace en 1985 mediante la Ley de Presupuesto Extraordinario N. 6995, se introdujo la Norma N. 177, que creaba la Corporacion de Servicios Multiples del Magisterio Nacional.;\";\";2018-07-18 22:08:03;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3007075876;2;INSTITUTO NACIONAL DE LAS MUJERES (INAMU);INAMU;Costa Rica;1998-04-08;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";1111111;Alejandra Mora Mora;OFICINAS CENTRALES;2;Trabajadora social, Costarricense, ;\";25278400;\";San Jose;0;X;N;\";\";0;0;0;1;0.0;images/inamu.png;Desde hace mÃ¡s de veinte aÃ±os, con diferentes denominaciones y caracterÃ­sticas especÃ­ficas, han ido surgiendo en los paÃ­ses mecanismos nacionales de promociÃ³n de las mujeres, tambiÃ©n conocidos como Oficinas Gubernamentales de la Mujer (OGM).alt....... <a href=\'http://www.inamu.go.cr/9\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:32:17;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3007111111;2;COMISION NACIONAL DE PREVENCION DE RIESGOS Y ATENCION DE EMERGENCIAS;CNE;CR;1986-05-01;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/CNE_logo.png;Institución pública rectora en lo referente a la coordinación de las labores preventivas de situaciones de riesgo inminente, de mitigación y de respuesta a situaciones de emergencia. Es un órgano de desconcentración máxima adscrito a la Presidencia de la República,.... <a href=\'https://www.cne.go.cr/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:31:02;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3007231686;1;CONSEJO NACIONAL DE VIALIDAD;CONAVI;CR;1996-02-02;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;S;\";\";\";0;0;0;1;0.0;images/conavi_.png;En el año 1996, se empezó a gestar en nuestro país un movimiento orientado a establecer un fondo vial financiado con un impuesto único al combustible. Este movimiento se basa en la experiencia positiva de otros países latinoamericanos como Chile, Argentina Colombia...<a href=\'http://www.conavi.go.cr/wps/portal/CONAVI\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:31:28;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3007270500;2;CONSEJO DE TRANSPORTE PUBLICO;CTP;CR;2000-03-28;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/CTP.png;El Consejo de Transporte Público, fue creado mediante la Ley 7969 (Ley Reguladora del Servicio Público del Transporte Remunerado de Personas en Vehículos en la Modalidad Taxi), publicada en el Diario Oficial “La Gaceta” No. 20, el 28 de febrero 2000, como órgano de desconcentración máxima, adscrito al Ministerio de Obras Públicas y Transportes.... <a href=\'http://www.ctp.go.cr/index.php?option=com_content&view=article&id=92&Itemid=107\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:31:53;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3007320067;2;INSTITUTO NACIONAL DE INNOVACION TECNOLOGICA AGROPECUARIA INTA;INTA;\";2016-11-13;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;0;0.0;\";\";\";\";2018-05-30 22:32:35;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3007521568;2;Servicio Fitosanitario del Estado;SFE;Costa Rica;1978-05-02;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";Sabana Sur, San José.;1;\";\";25493400;\";\";0;X;N;\";Costa Rica;0;0;0;1;0.0;images/ico_sfe.jpg;En 1975, dentro del MAG, se origina la Dirección de Servicios Técnicos Básicos, que más tarde daría paso a la creación de la Dirección de Sanidad Vegetal, cuyo nombre se oficializa con la publicación de la Ley No.6248 del 2 de mayo de 1978, en la Administración del Lic. Daniel Oduber.. <a href=\'https://www.sfe.go.cr/SitePages/QuienesSomos/InicioQuienesSomos.aspx\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:38:44;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3007547060;2;BENEMERITO CUERPO DE BOMBEROS DE COSTA RICA;BOMBEROS CR;\";1925-05-29;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;0;0.0;images/3007547060.png;Somos el ente rector en materia de capacitación para la atención y prevención de emergencias que son competencia del Cuerpo de Bomberos, brindamos un servicio de excelencia en todas nuestras actividades, con abnegación, honor y disciplina desde 1925.;\";\";2018-01-17 18:03:41;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3007661162;2;UNIDAD EJECUTORA DEL PROGRAMA PARA LA PREVENCION DE LA INCLUSION SOCIAL;MINISTERIO DE JUSTICIA Y PAZ;\";2016-10-09;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;/images/ico_BID.png;El objetivo general del Programa será contribuir a la prevención de la violencia y el delito en las áreas de intervención. El objetivo específico del Programa será fortalecer las capacidades de gestión y acción del MJP para ejecutar intervenciones en sus dos principales áreas de actuación: (i) prevención secundaria de la violencia a nivel nacional y local y (ii) rehabilitación y reinserción de la población en conflicto con la ley penal, a través de programas de prevención terciaria de la violencia...<a href=\"http://mjp.go.cr/uep/\" target=\"_black\"><img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:39:07;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('301123456;2;Nombre de la empresa;Nombre de la empresa;CR;2017-12-20;1;1;0;0;0;0;0;\";\";\";\";\";\";1 1803 0131;Nicolas;N/R;1;0;N/R;Nicolas;guillen_nicolas@live.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-12-20 06:51:38;WEB', NULL, NULL, NULL, NULL, NULL),
('3012682635;2;STEREOCARTO S.L.;STEREOCARTO;ESPAÑOLA;1965-01-01;2;206440727;\";2;15108410026012078;15108410010019531;\";\";\";\";\";\";\";AAB486058;Maria Soraya Colino Jimenez;San José, La Uruca, condominio Vía Millenium, apartamento No. 401, 100 este del ICT avenida 31;1;Ingeniera, nacionalidad Española, ;Alfonso Gómez Molina;60272377;agomez@stereocarto.com;San José, Central, Uruca, Condominio Vía Millenium Apto 401;0;P;\";A;CR;1;1;7;2;1.0;images/stereoCarto.png;En STEREOCARTO, hemos empleado medios propios para la captura de informacion espacial, realizando mas de siete mil horas de vuelo fotogramatrico con nuestros aviones Cessna, Partenavia y Beechcraft para obtención de imágenes areas con cámaras fotogramátricas Zeiss Intergraph y Leica, y datos LIDAR con sensores Leica, cubriendo más de quinientos millones de hectÃ¡reas con fotografÃ­a vertical y nubes de puntos láser, en mas de veinte paises de cuatro continentes.... <a href=\'http://stereocarto.com/inicio\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-07-12 18:23:29;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3014042047;1;MUNICIPALIDAD DE CURRIDABAT;MUN. CURRIDABAT;CR;1929-08-21;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;S;\";\";\";0;0;0;1;0.0;images/mun_curri.png;Curridabat es un cantón con antecedentes precolombinos, conformado en sus inicios por grupos indígenas huetares, de los cuales descienden los primeros poblados del lugar... <a href=\'http://www.curridabat.go.cr/resena-historica/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:39:36;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042048;2;MUNICIPALIDAD DE DESAMPARADOS;MUNI.DESAMPARADOS;\";1862-11-04;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042048.png;La Municipalidad de Desamparados procura que el cantón desarrolle su máximo potencial, en un pueblo que combina el territorio urbano y rural y cuya principal fortaleza son sus habitantes que trabajan en el día a día para lograr un mejor lugar para vivir y trabajar;\";\";2018-02-01 17:15:16;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042050;2;MUNICIPALIDAD DE ESCAZU;MUNI.ESCAZU;\";1848-12-07;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042050.png;La Municipalidad de Escazú es el ente rector de la administración y desarrollo de los habitantes del cantón de Escazú, de la provincia de San José, procurando el bienestar de todos sus habitantes y el manejo eficiente de los recursos.;\";\";2018-02-01 17:38:17;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042054;2;MUNICIPALIDAD DE MORA;MUNICIPALIDAD DE MORA;\";1883-05-25;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042054.jpg;La Municipalidad de Mora es la rectora del canton numero 7 de la provincia de San Jose, Costa Rica, establecido en 1883 con el nombre indigena de Pacaca, que en esa epoca llevaba la poblacion cabecera posteriormente denominada Colon, con la categoria de villa y actualmente Colon (hoy con categoria de ciudad). Mora fue calificado en el año 2011 como el Canton mas seguro de todo el pais, debido a su formacion rural y a su extremadamente bajo nivel de delincuencia, el cual es practicamente imperceptible.;\";\";2018-05-24 20:52:54;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042058;2;MUNICIPALIDAD  DE SAN JOSE;MUNI.SAN JOSE;CR;1841-01-01;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/msj.gif;En 1841, gracias a la promulgaciÃ³n de la Ley de Bases y GarantÃ­as, se establece un nuevo ordenamiento territorial del paÃ­s, en forma de cinco departamentos, con sus capitales en San JosÃ©, Cartago, Heredia, Alajuela y Guanacaste, y con la divisiÃ³n de cada uno de los departamentos en pueblos, barrios y cuarteles... <a href=\'https://www.msj.go.cr/MSJ/Capital/SitePages/historia_canton.aspx\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:40:21;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042059;2;MUNICIPALIDAD DE SANTA ANA;MUN. SANTA ANA;\";1907-10-15;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/muni_staana.png;En 1870 el Gobierno del General Guardia estableció la primera Alcaldía en Santa Ana, en Río de Oro. Santa Ana nace como cantón el 31 de agosto de 1907, mediante el Decreto No. 8 del 29 de agosto de 1907.... <a href=\'https://www.santaana.go.cr/\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:40:47;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042060;2;MUNICIPALIDAD DE TARRAZU;MUNI.TARRAZU;\";1868-08-07;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042060.jpg;Es el ente gubernamental encargado del desarrollo y administración del cantón de Tarrazú, de la provincia de San José, procurando las mejores vías para el desarrollo de todos sus vecinos, brindándoles los mejores servicios para este fin.;\";\";2018-02-01 17:22:20;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042061;2;MUNICIPALIDAD DE TIBAS;MUNI.TIBAS;\";1914-07-27;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042061.jpg;La Municipalidad de Tibás es el órgano encargado de la administración del cantón de Tibás, de la provincia de San José, promoverá la mejora en la calidad de vida de todos sus habitantes y el mejor manejo de sus recursos.;\";\";2018-02-01 18:10:46;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042062;1;MUNICIPALIDAD DE TURRUBARES;MUN. TURRUBARES;CR;2017-05-07;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;S;\";\";\";0;0;0;1;0.0;images/escudo+de+turrubares.png;Procedentes del sur del Valle Central occidental, en 1850 aproximadamente, numerosas familias buscaron las montaÃ±as aledaÃ±as con el afÃ¡n de nuevas y mÃ¡s productivas tierras. Entre viviendas alejadas al inicio y agrupadas poco a poco, se va formando una especie de cuadrante  que con el paso del tiempo da base a la parroquia de Santiago de Puriscal.... <a href=\'http://www.turrubares.go.cr/Historia\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:41:16;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042063;2;MUNICIPALIDAD DE ALAJUELA;MUNI.ALAJUELA;\";1848-12-07;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042063.jpg;La Municipalidad de Alajuela se creó por decreto el 7 de diciembre de 1848. Es el gobierno local del cantón central de la provincia de Alajuela, su función primordial es garantizar el bienestar de los Alajuelenses mediante una sana administración de los recursos, que permitan brindar servicios y obras locales de calidad, que brinden oportunidades para el desarrollo integral del Cantón en armonía con el ambiente. ;\";\";2018-01-22 15:06:11;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042066;2;MUNICIPALIDAD DE GRECIA;MUNICIPALIDAD DE GRECIA;\";2017-11-12;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;0;0.0;\";\";\";\";2018-05-30 22:41:38;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042079;2;MUNICIPALIDAD DE ALVARADO DE PACAYAS;MUNI.ALVARADO DE PACAYAS;\";1903-07-17;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042079.jpg;La Municipalidad de Alvarado busca potenciar el desarrollo de los habitantes del cantón, garantizando mejor calidad de vida con el uso eficiente de los recursos. ;\";\";2018-02-01 17:50:13;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042080;2;MUNICIPALIDAD DE CARTAGO;MUN. CARTAGO;cr;1998-01-01;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";188;1;1;1;1;1.0;images/municartago.png;El Ayuntamiento de Cartago fue fundado en 1563, por ende es el ayuntamiento mÃ¡s antiguo de Costa Rica y constituyÃ³ el Gobierno de Costa Rica, por ser Cartago la capital en ese momento. Posteriormente en 1813, de acuerdo a la constituciÃ³n promulgada en CÃ¡diz, EspaÃ±a, en el aÃ±o 1812,.... <a href=\'http://www.muni-carta.go.cr/nuestra-municipalidad/resena-historica.html\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:42:03;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042082;2;MUNICIPALIDAD DE EL GUARCO;MUNICIPALIDAD DE EL GUARCO;\";1939-07-26;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042082.png;Somos una institución amparada en el Régimen Municipal, que brinda servicios de calidad con continuidad, de forma democrática y participativa, contribuyendo al mejoramiento de la calidad de vida y al desarrollo humano local de los y las habitantes del cantón de El Guarco;\";\";2018-02-01 17:15:48;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042083;2;MUNICIPALIDAD DE LA UNION;MUNI.LA UNION;\";1848-12-07;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042083.png;Somos la institución rectora de La Unión, que impulsa el desarrollo socio-económico, cultural y recreativo, mejorando la calidad de vida de sus habitantes, en armonía con la naturaleza. Para lograrlo contamos con un equipo de trabajo motivado, comprometido y competitivo, apoyados en recursos materiales y tecnológicos idóneos.;\";\";2018-02-01 17:14:28;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042086;2;MUNICIPALIDAD DE PARAISO;MUNI.PARAISO;\";1848-12-07;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042086.jpg;Desarrollamos las capacidades institucionales y ciudadana disponibles en el cantón Paraíso, que mejoren la calidad de vida de sus habitantes en el marco del desarrollo humano, social, económico, político, y cultural, con equidad de género.;\";\";2018-02-01 17:58:47;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042088;2;MUNICIPALIDAD DE TURRIALBA;MUNI.TURRIALBA;\";1903-08-25;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042088.jpg;Somos el gobierno local que brinda servicios públicos, realiza y articula proyectos sociales, ambientales y económicos para los habitantes y su desarrollo integral en el cantón de Turrialba.;\";\";2018-02-01 18:02:28;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042092;1;MUNICIPALIDAD DE HEREDIA;MUNI.HEREDIA;CR;1848-12-07;0;801070063;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;S;\";\";Costa Rica;0;0;0;1;0.0;images/muni_heredia.png;La Municipalidad debe atender las funciones de:  fomentar la participaciÃ³n activa de la ciudadanÃ­a en la toma de decisiones, ofrecer servicios como recolecciÃ³n de residuos, limpieza de calles y caÃ±os, mantenimiento y construcciÃ³n de Ã¡reas pÃºblicas, la administraciÃ³n de cementerios municipales, administraciÃ³n del Mercado Municipal, mantenimiento y construcciÃ³n de vÃ­as cantonales.... <a href=\'https://www.heredia.go.cr/es/municipalidad\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-02-01 16:45:06;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3014042097;2;MUNICIPALIDAD DE SANTO DOMINGO;MUNI,STO DOMINGO;\";1848-12-07;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3014042097.png;La Municipalidad de Santo Domingo tiene como misión la promoción de un desarrollo integral y sostenible de los habitantes  del cantón de Santo Domingo de Heredia; mediante la prestación eficiente de los servicios municipales, el desarrollo de proyectos y la aplicación de las  competencias de gobierno local.;\";\";2018-02-01 17:02:06;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('301442085;2;MUNICIPALIDAD DE OREAMUNO;MUNICIPALIDAD DE OREAMUNO;\";1950-08-17;0;2147483647;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;\";En la administración de don Alfredo González Flores, el 17 de agosto de 1914, en ley No. 68 se le otorgó el título de Villa al pueblo de San Rafael, cabecera del cantón creado en esa oportunidad. Posteriormente el 6 de diciembre de 1963, en el gobierno de don Francisco Orlich Bolmarcich, se decretó la ley No. 3248, que le confirió a la villa, la categoría de Ciudad.;\";\";2018-02-07 16:37:12;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('304150114;1;Melina Obando Salas;Melina Obando Salas;cr;2017-10-21;1;1;0;10;0;0;0;\";\";\";\";\";\";304150114;Melina;N/R;1;0;N/R;Melina;mel.obando@gmail.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-10-21 20:48:30;WEB', NULL, NULL, NULL, NULL, NULL),
('3101005744;2;PURDY MOTOR SOCIEDAD ANONIMA;PURDY MOTOR TOYOTA;\";1957-01-08;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;2;0.0;images/3101005744.png;El 8 de enero de 1957, don Xavier Quirós Oreamuno fundó Purdy Motor. En la década de 1950 con la construcción de la carretera Panamericana el Toyota Land Cruiser se convirtió en el mejor aliado de los productores costarricenses, debido a que la mayoría de caminos eran en lastre. A través de los últimos 60 años Purdy Motor se ha consolidado como la principal compañía distribuidora de vehículos en Costa Rica, con sus marcas Toyota, Dahiatsu y Lexus...<a href=\'https://www.toyotacr.com/purdy-historia/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-02-07 21:50:40;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101007749;2;REFINADORA COSTARRICENSE DE PETROLEO SOCIEDAD ANONIMA;RECOPE;CR;1961-01-01;0;2147483647;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/recope.png;1961; Un grupo privado funda RECOPE e inicia gestiones para obtener los permisos del Ministerio de Economía, Industria y Comercio con....... <a href=\'https://www.recope.go.cr/quienes-somos/historia/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-06-16 20:57:30;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3101009059;2;RADIOGRAFICA COSTARRICENSE SOCIEDAD ANONIMA;RACSA;\";1964-06-18;0;3101727041;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3101009059.png;Por Ley Nº 3293 del 18 de junio de 1964, el ICE y la Compania Radiografica Internacional de Costa Rica formaron una sociedad mixta, a partes iguales, denominada Radiografica Costarricense, S.A. (RACSA), por un plazo social de trece años. Durante la decada de los ochenta, RACSA introdujo al mercado nacional novedosos servicios de telecomunicaciones, como RACSAFAX para la transferencia de información escrita, y RACSAPAC (Red Pública de Datos X.25), tercera de su especie instalada en Latinoamerica, para brindar servicios de comunicacion a nivel nacional y centroamericano. En 1992, la Asamblea Legislativa, con la Ley No.7298, amplio el plazo social de RACSA por 25 años mas. En 1994 RACSA inicio la comercializacion en el pais del servicio Internet. Para conocer en detalle el desarrollo de este servicio en el país.;\";\";2018-07-10 23:35:11;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101011173;2;ROMA PRINCE S.A;PASTAS ROMA;CR;1961-01-01;0;2147483647;\";6;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;P;\";\";\";0;0;0;0;0.0;images/3101011173_logor;En un pequeño local, en el año 1961, la Compañía Pastas Alimenticias Roma, S.A., inició sus actividades con el firme propósito de fabricar las mejores pastas del país. A base de esfuerzos las Pastas Roma fueron introduciéndose en el mercado nacional, y en pocos años llegaron a ser las de más ventas en el país.  En el año 1973, el nombre “Pastas Alimenticias Roma, S.A.”, fue cambiado a “Roma Prince, S.A.”, Aunque los productores siguieron conociéndose como Pastas Roma. El ritmo ascendente de la compañía exigió que en 1976 se trasladara las instalaciones originales en Escazú a un edificio situado en la ciudad de Alajuela.  La gran aceptación y demanda por las Pastas Roma hizo necesario el cambio y modernización del equipo de fabricación. Fue así que en 1987 se tomó la decisión de adquirir la mejor maquinaria para la fabricación de pastas largas, por lo que se importó desde Italia una línea de producción de alta temperatura de la marca Pavan, En ese momento Roma Prince, se convirtió en la;\";\";2017-11-07 17:26:08;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101012009;2;BAC SAN JOSE COSTA RICA S.A.;BAC;CR;1952-01-01;1;2147483647;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;2;0.0;images/logoBACcredomatic.png;Los inicios del Grupo BAC Credomatic se remontan a más de medio siglo atrás, cuando en 1952 se fundó el Banco de América, en Nicaragua. Sin embargo, no fue sino hasta los años setenta cuando se incursionó en el negocio de tarjetas de crédito,  mediante las empresas Credomatic...... <a href=\'https://www.baccredomatic.com/es-cr/nuestra-empresa/historia\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-01-05 16:29:27;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('31010273496;2;FLORIDA BEBIDAS S.A.;FIFCO;CRC;1908-01-01;0;\";\";2;\";\";\";\";\";\";\";\";\";\";\";\";0;\";\";\";\";\";1;X;N;G;188;4;408;40803;2;0.0;images/fifco.png;Florida Ice and Farm Company (FIFCO) naciÃ³ en 1908, en La Florida de Siquirres, provincia de LimÃ³n, Costa Rica. Fue fundada por cuatro hermanos de origen jamaicano de apellidos Lindo Morales, como una empresa dedicada a la agricultura y la fabricaciÃ³n de hielo.\nEn 1912, los hermanos Lindo adquirieron la CervecerÃ­a y RefresquerÃ­a Traube....<a href=\'http://www.florida.co.cr/Historia\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2016-05-18 00:00:00;dba', NULL, NULL, NULL, NULL, NULL),
('310103321935;2;MULTI MARKET SERVICES COMMUNICATION COSTA RICA SA;MULTI.MARKET;CR;2017-01-01;1;1;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;P;\";\";\";0;0;0;0;0.0;\";\";\";\";2017-01-27 18:49:52;Gerson', NULL, NULL, NULL, NULL, NULL),
('3101036581;2;SEGURICENTRO SOCIEDAD ANONIMA.;SEGURICENTRO S.A.;CR;2013-10-24;1;206440727;0;9;15109110026001718;15109510010010344;0;\";\";\";\";\";\";108790230;Sergio Jose Zoch Rojas;San Jose, Moravia, La Guaria.  Frente al Colegio San Joseph;1;Ingeniero Industrial;Sergio Jose Zoch Rojas;22568080;sjzoch@seguricentro.com;San Jose, Moravia, La Guaria.  Frente al Colegio San Joseph;1;P;N;\";CR;1;1;1;2;0.0;images/seguricentro.png;Misión:\r\nComercializar equipos de seguridad de vanguardia, a través de un equipo de trabajo capacitado y motivado para brindar el mejor servicio y asesoría a nuestros clientes...<a href=\'http://www.seguricentro.com/?action=empresa\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-11-27 20:38:05;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3101063817;2;Temafra S.A;Temafra;CR;2017-05-22;1;801070063;\";2;15100010026163394;15100010012080428;\";\";\";\";\";\";\";\";\";\";1;\";Lisbeth Salguera;2258-28-07 ext 4510;matambul@gmail.com;\";0;P;N;\";\";0;0;0;0;0.0;\";\";\";\";2017-11-07 22:51:42;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `TABLE 37` (`COL 1`, `COL 2`, `COL 3`, `COL 4`, `COL 5`, `COL 6`) VALUES
('3101081676;2;AXIOMA INTERNACIONAL S,A, ;AXIOMA;CR;1998-01-01;1;801070063;\";9;10200009119791932;10200009119787735;\";\";\";\";\";\";\";601820513;José Rolando Alvarado Avellán ;San José, Central, Uruca, Del Hotel Best Western Irazú, 125 al este;4;INGENIERO ELÉCTRICO, Costarricense, ;Oscar Esquetini ;2290 9243;Oscar.esquetini@axioma.co.cr;San José, Central, Uruca, Del Hotel Best Western Irazú, 125 al este ;0;P;N;A;CR;1;1;7;2;0.0;images/axioma.png;Axioma tiene más de 20 años de presencia en el mercado nacional. Contamos con amplia experiencia en la administación técnica y construcción de grandes proyectos de integración de tecnologías de transporte de información. Proveemos a nuestros clientes soluciones de comunicaciones con un alto nivel de calidad<a href=\'http://www.axioma.co.cr/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a> ;\";\";2018-07-12 18:16:19;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3101091284;2;Veromatic;Veromatic;CR;2018-03-08;1;801070063;0;0;0;0;0;\";\";\";\";\";\";110360450;Max;N/R;1;0;N/R;Max;max.serrano@veromatic.net;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-02-12 17:41:09;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3101098063;2;MULTINEGOCIOS INTERNACIONALES AMERICA S.A.;Multiasa;CR;1990-01-01;3;801070063;\";2;\";15201001016949878;\";\";\";\";\";\";\";107820640;Adrián Madrigal Cerdas;San José, Santa Ana, Río Oro;4;ADMINISTRACIÓN DE EMPRESA, Costarricense, ;Fernando Madrigal Cerdas;87081812;amadrigal@mutiasa.com;San José, Barrio Corazón de Jesús, contiguo a Yanber, Bodegas piso Pisos S.A 11;0;P;N;A;CR;1;1;3;2;0.0;images/multiasa.png;Actualidad con más de 150 contratos distribuidos en 750 lugares en todo el país, contando con un canal de distribución adecuada, un  cuerpo de supervisión constante y más de 1450 empleados  para poder brindar un excelente servicio a nuestro cliente.<a href=\'http://www.mutiasa.com/index.php\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a> ;\";\";2017-06-22 17:09:00;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101114047;2;CONSTRUCTORA PRESBERE SA;CONSTRUCTORA PRESBERE SA;CR;1991-11-01;1;2147483647;0;9;0;15109610010009100;0;\";\";\";\";\";\";112630338;Marvin Alberto Oviedo Mora;San José,  Aserrí, Barrio María Auxiliadora, 350 metros sureste del taller de buses Mario Morales;2;Empresario;Alonso Oviedo Mora;22304089;aoviedo@presbere.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";Fundamentada en la producción y colocación de mezcla asfáltica en caliente, tanto para entidades públicas como privadas a nivel nacional.  Con el paso de los años y tras la necesidad de nuestros clientes, se incursionó en otros servicios de infraestructura vial, como lo son movimientos de tierras, alcantarillados sanitarios y pluvial, canalizaciones y otro tipo de pavimentos tales como los rígidos, adoquinados y tratamientos bituminosos superficiales, servicios que brindamos entre otros hasta el día de hoy, incursionando de esta manera, en diferentes áreas de la construcción.;\";\";2018-02-01 18:51:36;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3101117297;2;DISEÑO ARQCONT S.A;ARQCONT S.A;CR;1985-04-01;0;801070063;\";9;15201001044392601;15201001044392363;\";\";\";\";\";\";\";601560512;FRANCISCO MORA ROJAS;Heredia, Ulloa, 400 metros suroeste de la entrada principal del Condominio La Ladera;2;Arquitecto;Francisco Mora Rojas;83836068;arqcontcr@gmail.com;Heredia, Ulloa, 400 metros suroeste de la entrada principal del Condominio La Ladera;0;P;\";\";\";0;0;0;2;0.0;images/3101117297.A;Somos una Empresa dedicada a la construccion y consultoria, brindamos sus servicios en el campo de infraestructura (inmobiliario) desde 1985. Nos especializamos en la innovacion de diseño y en la busqueda de alternativas a sistemas constructivos acorde a las exigencias actuales y segun necesidades de los clientes, bajo un estricto respeto por el medio. Cuenta con personal altamente capacitado tanto profesional como tecnico para la realizacion de las labores que ofrece. Nuestra actividad esta respaldada por maquinaria y equipo de ultima generacion y laboratorio especializado con alta tecnologia. Hemos desarrollado a lo largo de estos 25 años proyectos Institucionales con mas de 37.223 m2 y privados con un aproximado 22.500 m2.;\";\";2018-07-12 18:12:27;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3101127663;2;CREACIONES PUBLICITARIAS INTER S.A.;CREACIONES;CR;2009-08-20;1;801070063;\";9;15109110026003114;15109110010008368;\";\";\";\";\";\";\";109500826;Sonia Rodriguez Pérez;San José, Tibas, Llorente, 75 mts Este Price Smart  Apartamentos La Macha;4;PUBLICISTA, Costarricense, ;Sonia Rodriguez Pérez;8309-9636;srodriguez@creacionescr.com;San José, Vásquez de Coronado, Patalillo, 300 este del Mall Don Pancho ;0;P;N;A;Costa Rica;1;11;4;2;0.0;images/logo_creaciones_p.png;Agencia de Publicidad y Mercadeo, diseño de experiencias publicitarias BTL y eventos..... <a href=\'https://es-la.facebook.com/pg/creacionespublicitariasCR/about/?ref=page_internal\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-07-12 18:16:44;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3101142660;2;New Medical S.A;New Medical S.A;CR;2017-09-27;1;1;0;2;0;0;0;\";\";\";\";\";\";106120472;Miguel ;N/R;1;0;N/R;Miguel ;info@newmedicalcr.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-09-27 18:45:00;WEB', NULL, NULL, NULL, NULL, NULL),
('3101151258;2;Chaso del Valle S.A.;Chaso del Valle;CR;2002-03-04;0;206440727;\";6;11400007910462751;15114210010000902;\";\";\";\";\";\";\";107830445;Francisco Jose Soto Sagot;San Jose, Desamparados, San Antonio, Residencial Boulevard casa 31a;2;Comerciante;Francisco Soto Sagot;83813203;fsoto@chaso.com;\";0;P;\";\";\";0;0;0;2;0.0;/images/chaso.png;Empresa especializada en el diagnóstico para la calidad e inocuidad de los alimentos desde la granja hasta la mesa y la calidad del agua . Ofrecemos pruebas de diagnóstico de campo, servicio de análisis de laboratorio y plataformas de inspección. Para la mejora y el bienestar de la salud humana, la salud animal y calidad ambiental... <a href=\'https://www.chaso.com/\' alt=\'+info\' target=\"_black\"/><img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-12-14 23:03:50;Gerson', NULL, NULL, NULL, NULL, NULL),
('3101172938;2;CONSTRUCTORA HERMANOS BRENES S.A, ;Constructora Brenes;CR;1992-01-01;1;206440727;\";9;15107510026001058; 15107510010082221 ;\";\";\";\";\";\";\";3-0197-0458;HUGO ERNESTO  BRENES GONZALEZ;Cartago, El Guarco, Tejar;2;Empresario, Costarricense, ;Maricruz Montero;40017355;mmontero@hermanosbrenes.com;Cartago, El Guarco, Zona Industrial;0;P;\";A;CR;3;1;2;2;0.0;images/hnos_brenes.jpg;Alquiler de maquinaria pesada, construcción de caminos, carreteras, puentes, canales de drenaje en todo tipo de terreno, así como construcción de infraestructura para proyectos urbanísticos ... <a href=\'https://es-es.facebook.com/Constructora-Hermanos-Brenes-124466530924720\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-06-07 21:39:28;Gerson', NULL, NULL, NULL, NULL, NULL),
('3101176555;1;HOSPITAL SAN JOSE SOCIEDAD ANONIMA;HOSPITAL CIMA;CR;1994-05-01;2;2147483647;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;S;\";\";\";0;0;0;2;0.0;images/cima.png;La idea inicial fue construir un hogar especializado en la atenciÃ³n de personas mayores; sin embargo, la iniciativa evolucionÃ³ hasta convertirse en el centro de especialidades mÃ©dicas con mayor proyecciÃ³n en la regiÃ³n: El Hospital CIMA San JosÃ©....... <a href=\'http://cimaweb.azurewebsites.net/quienes-somos/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-05-19 20:11:44;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3101200102;2;CONSTRUCCIONES PENARANDA SOCIEDAD ANONIMA;CONSTRUCTORA PENARANDA S.A;CR;1997-02-01;0;2147483647;\";9;\";15102010010046521;\";\";\";\";\";\";\";401500070;Marco Penaranda Chinchilla;San Ramón, Alajuela;2;Ingeniero;Jose Cuadra Arroyo;24450254;jcuadra@conpesa.com;San Ramón, Alajuela;0;P;\";\";\";0;0;0;2;0.0;images/3101200102.png;CONSTRUCCIONES PENARANDA S.A, fundada en 1997, es una empresa constructora enfocada a la Remodelación y Construcción de Obras Civiles, así como el alquiler de maquinaria: Vagonetas y Back Hoe, entre otros. Uno de los principales objetivos de la empresa es hacer de la construcción una actividad productiva de la mejor calidad, alcanzando los mejores resultados técnicos y económicos;\";\";2018-02-20 20:03:00;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101203019;2;CONSTRUCTORA Y CONSULTORA WIND Y ASOCIADOS, S.A. ;WIND_S.A.;CR;2016-11-30;1;1;\";2;0;0;\";\";\";\";\";\";\";\";Ernesto Wind Barroca;Curridabat, Granadilla;1;\";\";\";ewind@windconsultores.com;\";0;P;\";\";\";0;0;0;0;0.0;\";\";\";\";2016-11-30 08:17:34;gerson78', NULL, NULL, NULL, NULL, NULL),
('3101213117;2;COMANDOS DE SEGURIDAD UNIVERSAL S.A;SEGURIDAD DELTA;CR;2017-04-19;1;801070063;\";2;\";15100010011579953;\";\";\";\";\";\";\";\";\";\";1;\";Jesenia Morales;4035-2135;lvega@seguridaddelta.com, JMORALES@seguridaddelta.com;\";0;P;\";\";188;1;1;1;2;1.0;\";\";\";\";2017-05-09 15:43:08;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3101220952;2;KANI MIL NOVECIENTOS UNO SOCIEDAD ANONIMA;KANI;Costa Rica;2003-02-01;1;1;\";2;\";\";\";\";\";\";\";\";\";1-0789-0344;JOSE ALBERTO OLLER ALPIREZ;SAN PEDRO DE MONTES DE OCA;2;ADMINISTRACIÓN DE EMPRESA, Costarricense, ;FLORIA LIZ SALAZAR VARGAS;25370102;\";\";0;X;\";A;Costa Rica;0;0;0;0;0.0;\";\";\";\";2017-01-24 14:59:31;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3101223757;2;CORPORACION CENELEC S.A;Cenelec;CR;2008-08-01;1;801070063;\";9;15201001028736567;15201001025012283;\";\";\";\";\";\";\";503040109;Allan Pineda Obando;Heredia, San Pablo;2;Comerciante, Costarricense, ;Cristel López;22222626;ventas3@cenelec.cr;San José, Central, Plaza Víquez, Diagonal a la entrada a las piscinas;0;P;\";A;Costa Rica;1;1;4;2;0.0;images/cenelec.jpg;Empresa con 15 aÃ±os de trayectoria. Nos dedicamos a brindar servicios en las Ã¡reas de LÃ­nea Blanca, LÃ­nea MarrÃ³n y Aires AcondicionadosSomos una empresa con mas de 15 aÃ±os de trayectoria, dedicada a la ReparaciÃ³n de electrodomÃ©sticos, Venta, InstalaciÃ³n y reparaciÃ³n de Aires Acondicionados, ademÃ¡s de la venta de repuestos originales de las marcas LG, Whirlpool, Panasonic, Sony, Starlight, Toolcraft y muchas mas. <a href=\'http://www.grupocenelec.com\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a> ;\";\";2018-07-12 18:18:50;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3101225198;2;CONSTRUCTORA CONTEK S.A;CONTEK S.A;CR;1998-05-19;0;206440727;\";9;11400007811152664;11400007011229188;\";\";\";\";\";\";\";108010458;Óscar Marín Zamora;Residencial Loma Verde, Curridabat, San José;2;Ingeniero Civil;Óscar Marín Zamora;60593251;omarin@contekcr.com;100 este y 100 sur del BNCR, Curridabat;0;P;\";\";\";0;0;0;2;0.0;images/3101225198.png;Somos una empresa constructora especializada en construcción de condominios, casas de habitación y edificios. Experiencia en proyectos de participación pública • Renovación de varias sedes del Banco Nacional...<a href=\'http://contekcr.com/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-07-16 20:37:00;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101235381;2;NOVUS MENSAJERIA S.A.;NOVUS;CR;2004-10-03;2;206440727;\";9;\";10200009049894071;\";\";\";\";\";\";\";700700101;LUBADINIA LEON MARENCO;San Vicente ,Santo Domingo, Heredia;4;Administradora, Costarricense, ;Criss Mora;22906611 Ext. 105;tesoreria@novuscr.com;San José, Central, Sabana Norte, del Banco Improsa 100 norte 50 oeste y 175 norte;0;P;\";A;CR;1;1;8;2;0.0;images/novus.png;Empresa especializada en brindar servicios de entrega de documentación y paquetería en todo el territorio nacional. Nuestra promesa de valor es la entrega en un tiempo máximo de 24 horas. <a href=\'http://novuscr.com/ \' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:23:08;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3101254525;2;ESTRUCONSULT SOCIEDAD ANONIMA;ESTRUCONSULT S.A;CR;1999-10-04;0;3101727041;\";12;15109210026003391;\";\";\";\";\";\";\";\";106690153;Orlando Gei Brealey;Pozos de Santa Ana, San Jose;2;Ingeniero Civil;Orlando Gei Brealey;83844479;ogei@estru.com;Pozos de Santa Ana, San Jose;0;P;\";\";\";0;0;0;2;0.0;images/LOGO-ESTRUCONSULT.png;EstruConsult S.A es una empresa costarricense, esta constituida por un grupo de profesionales con especialidad en las areas de Ingenieria civil y estructural. El grupo posee amplia experiencia profesional en la region centroamericana, complementada con trayectoria academica en prestigiosas universidades.;\";\";2018-06-20 14:59:04;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101260434;2;HAMBURG SUD COSTA RICA SOCIEDAD ANONIMA;HAMBURG SUD;Costa Rica;2009-01-01;1;801070063;\";2;\";\";\";\";\";\";\";\";\";\";Marcus Fred. Brusius;Escazú Corporate Center, Piso 7, SJ, CR;2;\";Maria Rivera;25193314;maria.rivera@hamburgsud.com, marcus.brusius@hamburgsud.com;Escazú Corporate Center, Piso 7, SJ, CR;0;X;\";\";1;1;1;1;2;1.0;images/hamburg_sud.png;1871: FundaciÃ³n de la Hamburg SÃ¼damerikanische Dampfschifffahrts-Gesellschaft como sociedad anÃ³nima, por once representantes de casas de comercio de Hamburgo. Tres buques con casi 4.000 TRB realizan un servicio de lÃ­nea mensual a Brasil......... <a href=\'https://www.hamburgsud.com/group/es/corporatehome/company/history/index.html\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-05-18 22:44:33;Gerson', NULL, NULL, NULL, NULL, NULL),
('3101265330;2;XISA Constructora SA;XISA;CR;2017-06-27;1;2147483647;0;6;15123810020000549;15105410010012882;0;\";\";\";\";\";\";302870479;Erick Brenes Vasquez;Cartago, del servicentro el Guarco 100 metros sur y 50 metros oeste;1;Administrador, Costarricense, ;Erick Brenes Vasquez;25720973;ebrenes@xisa.net;N/R;1;P;N;\";CR;1;1;1;2;0.0;\";\";\";\";2017-06-27 21:32:43;Gerson', NULL, NULL, NULL, NULL, NULL),
('3101295868;2;DISTRIBUIDORA LA FLORIDA SOCIEDAD ANONIMA;FIFCO;CR;2001-05-24;0;\";\";2;\";\";\";\";\";\";\";\";\";\";\";\";0;\";\";\";\";\";1;P;N;G;IND;4;408;40803;1;2.8;images/fifco.png;Florida Ice and Farm Company (FIFCO) naciÃ³ en 1908, en La Florida de Siquirres, provincia de LimÃ³n, Costa Rica. Fue fundada por cuatro hermanos de origen jamaicano de apellidos Lindo Morales, como una empresa dedicada a la agricultura y la fabricaciÃ³n de hielo.En 1912, los hermanos Lindo adquirieron la CervecerÃ­a y RefresquerÃ­a Traube....<a href=\'http://www.florida.co.cr/Historia\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2016-05-18 00:00:00;dba', NULL, NULL, NULL, NULL, NULL),
('3101300763;2;Distribuidora de Frutas, Carnes y Verduras Tres M,S.A.;Distribuidora de Frutas, Carnes y Verduras Tres M,;CR;2018-02-15;1;1;0;0;0;0;0;\";\";\";\";\";\";107510294;Carlos;N/R;1;0;N/R;Carlos;chernand68@yahoo.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-02-15 09:54:28;WEB', NULL, NULL, NULL, NULL, NULL),
('3101314088;2;AGREGADOS H Y M SOCIEDAD ANONIMA;AGREGADOS H Y M;CR;1978-01-01;1;2147483647;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;P;N;A;CR;0;0;0;2;0.0;images/agregados_hym.jpg;Desde el 2013 H&M enfoca su crecimiento en el concreto premezclado, ampliando operaciones en Guanacaste y posteriormente en el Coyol de Alajuela, con dos modernas plantas de concreto y bombas telescópicas. Además se adquirió una planta móvil para servir proyectos masivos en sitios alejados.\n\nHoy contamos con cuatro centros de producción y distribución en Costa Rica: Santa Clara (oficinas centrales) y San Josecito en San Carlos y más recientemente Península de Papagayo en Guanacaste y Coyol de Alajuela, donde le esperamos para que conozca las mejores plantas de producción tanto de concreto como de agregados y la moderna y eficiente flotilla de equipo pesado, pero sobre todo el gran equipo humano que nos colabora... <a href=\'http://www.grupohym.com\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-06-26 16:47:18;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3101316814;2;GRUPO OROSI S.A.;GRUPO OROSI S.A.;CR;2005-05-31;1;206440727;0;9;CR38015123810020000118;CR24015105410010004761;0;\";\";\";\";\";\";301971312;ELADIO ARAYA MENA;Cartago, Agua Caliente 500 metros de la Iglesia;2;Empresario;KATTIA ARAYA MARTINEZ;22595895;KARAYA@OROSICR.COM;CURRIDABAT;1;P;N;\";CR;1;1;1;2;0.0;images/orosi_ico.png;Nuestra Organización se dedica a la construcción de obras de infraestructura y de ingeniería civil. Nos especializamos en ofrecer a nuestros clientes soluciones integrales, desde movimientos de tierra y “agregados de calidad Orosi”, hasta la gestión de proyectos exitosos. Administramos con excelencia obras y proyectos sin distinción de tamaño; nuestro trabajo es preciso y el servicio nuestra vocación. Cuenta con certificación ISO 9001.... <a href=\'http://orosicr.com/quienes-somos.html\' target=\'_black\' alt=\'+info\' height=\"25\" width=\"25\"/>(+ info)</a>;\";\";2018-06-25 23:14:01;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101320803;2;JCB CONSTRUCTORA Y ALQUILER S.A.;JCB;CR;2004-01-01;4;801070063;\";6;\";15100610010054393;\";\";\";\";\";\";\";110370745;JUAN CARLOS BOLAÑOS ROJAS;GUACHIPELIN DE ESCAZU, SAN JOSE;2;EMPRESARIO, Costarricense, ;\";22960082;JCBOLANOS@GRUPOJCB.COM;\";0;P;\";A;CR;0;0;0;2;0.0;\";\";\";\";2018-03-14 22:47:22;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101376814;2;ADC MOVIL CRI S.A.;ADC MOVIL;CR;2004-07-23;1;801070063;\";2;10700000000091445;\";\";\";\";\";\";\";\";108090970;RODOLFO SOJO GUEVARA;San José, Central, Mata Redonda, 400 metros sur del AM PM;2;INFORMATICO, Costarricense, ;ORLANDO SOLIS;22317275;OSOLIS@ADCMOVIL.COM;OFICENTRO LA SABANA EDIFICIO 2  PISO 2;0;P;N;A;CR;1;1;8;2;0.0;images/adc_movil.png;ADC Movil es una companÌa fundada en el año 2004, dedicada a integrar Soluciones TecnoloÌgicas (software, hardware y networking) especializadas, para la RecoleccioÌn ElectroÌnica de datos dirigidas a empresas y organizaciones puÌblicas o privadas independientemente de su giro de negocios.\n<a href=\'http://adcmovil.com/v2/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a> ;\";\";2017-06-22 16:35:45;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101383592;2;INMOBILIARIA BERLIZ SOCIEDAD ANONIMA;INMOBILIARIA BERLIZ S.A;CR;2012-07-10;0;3101727041;\";9;\";16100014104489993;\";\";\";\";\";\";\";108200490;BERNAL AGUILAR CORDERO;Alajuela, Grecia, Santa Gertrudis Norte;2;Ingeniero;Bernal Aguilar Cordero;24443609;inmoberliz@gmail.com;Alajuela, Grecia, Santa Gertrudis Norte, de la escuela 150 sur y 125 suroeste;0;P;\";\";\";0;0;0;2;0.0;\";Somos una empresa de capital costarricense, nos enfocamos en las areas de construccion y mantenimiento. Hemos desarrollado proyectos para el Gobierno Central, ICE, Municipalidad de Alajuela, RACSA, entre otras entidades del gobierno de Costa Rica. Nos caracterizamos por el excelente servicio y el cumplimiento de los mejores estandares de calidad.;\";\";2018-07-10 23:17:12;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101384104;2;INVERSIONES NATURARZA;NATURARZA;CR;2017-05-05;1;2147483647;\";2;CC11400007455416931;CC11400007355420811;\";\";\";\";\";\";\";\";\";\";1;\";ARACELI VALVERDE;86722772;financial@inversionesnaturarza.com;1;1;P;N;\";1;1;1;1;1;1.0;\";\";\";\";2017-05-05 20:28:51;Gerson', NULL, NULL, NULL, NULL, NULL),
('3101393948;2;Agrileasing Latinoamericano S. A.;Agrileasing Latinoamericano S. A.;CR;2017-08-17;1;1;0;2;0;0;0;\";\";\";\";\";\";132000085615;Alejandro;N/R;1;0;N/R;Alejandro;alex@agrileasingsa.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-08-17 14:32:37;WEB', NULL, NULL, NULL, NULL, NULL),
('3101395022;2;Inversiones Colmetex;Inversiones Colmetex;CR;2018-07-12;1;1;0;0;0;0;0;\";\";\";\";\";\";2663147;Daniela ;N/R;1;0;N/R;Daniela ;dmontenegro@colmetex.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-07-12 15:27:23;WEB', NULL, NULL, NULL, NULL, NULL),
('31014036495;2;PRO IN MSA SOCIEDAD ANONIMA;PRO IN MSA;CR;1980-02-01;1;2147483647;\";6;74010220405146;74010210405145;\";\";\";\";\";\";\";\";\";\";2;EMPRESARIO;\";\";\";HEREDIA, San Anotnio de Belen;0;P;\";\";\";0;0;0;0;0.0;\";\";\";\";2017-07-27 18:06:34;Gerson', NULL, NULL, NULL, NULL, NULL),
('3101417130;2;Servicios Hospitalarios Latinoamericanos Integrados (S.H.L.I.) ;Hospital La Catolica;\";1963-03-16;0;801070063;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";22463000;\";San Antonio de Guadalupe, Goicoechea, Costa Rica, frente a los Tribunales de Justicia.;0;X;\";\";\";0;0;0;2;0.0;images/3101417130.png;Hospital La Católica abrió sus puertas el 16 de marzo de 1963 como una nueva alternativa en la medicina privada. Esta iniciativa estuvo a cargo de un grupo de religiosas de la Congregación Hermanas Franciscanas de la Purísima Concepción y médicos, identificados con el bienestar de los costarricenses. Con el pasar del tiempo el Hospital se distinguió por su atención única y compromiso con la salud y la vida de cada uno de sus pacientes. Somos un hospital que contribuye a MEJORAR LA CALIDAD DE VIDA DE NUESTROS PACIENTES, con los más ALTOS ESTÁNDARES de excelencia.;\";\";2018-02-22 17:28:04;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3101439852;2;LG SERVICIOS ESPECIALIZADOS S.A.;LG;CR;2006-05-05;1;206440727;\";9;15118420020024979;15118420010136677;\";\";\";\";\";\";\";5-0304-0109;Allan Eddie Pineda Obando;Heredia, San Pablo;2;Comerciante, Costarricense, ;Cristel López;22222626;clopez@lgservicios.net;San José, Central, Plaza Víquez, Diagonal a la entrada a las piscinas;0;P;\";A;CR;1;1;4;2;0.0;images/LG.png;DIRECCION: Plaza Viquez, 200 Norte de la Ferreteria el Pipiolo, San Jose.  <a href=\'https://www.facebook.com/Taller-de-Servicio-Autorizado-LG-Costa-Rica-1656629054620826/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-07-12 18:18:14;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('310146536;2;SCOTIABANK DE COSTA RICA S.A;SCOTIABANK;\";1995-01-04;0;801070063;\";6;\";\";\";\";\";\";\";\";\";1729973;MANFRED ANTONIO SAENZ MONTERO;\";2;LICENCIADO EN DERECHO;\";\";\";\";0;X;\";\";\";0;0;0;2;0.0;images/scotia_ico.png;', NULL, NULL, NULL, NULL, NULL),
('El Grupo BNS de Costa Rica es una subsidiaria de The Bank of Nova Scotia. Ingresó a Costa Rica en 1995 ofreciendo al mercado nacional una amplia gama de productos y servicios financieros en sectores de Banca de Personas', ' Banca Comercial y Corporativa', ' Pymes', ' además de Fondos de Inversiones', ' Leasing', ' Seguros y Banca Privada ... <a href=\'http://www.scotiabankcr.com/Acerca/Quienes-somos/Perfil-corporativo/scotiabank-en-costa-rica.aspx\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-08-31 23:21:04;Gerson'),
('3101472019;2;Servicios integrados aduanales shekina s.a;Servicios integrados aduanales shekina s.a;CR;2018-06-27;1;1;0;0;0;0;0;\";\";\";\";\";\";203920483;JUANCARLOS ;N/R;1;0;N/R;JUANCARLOS ;ecervantes@shekinacr.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-06-27 15:51:03;WEB', NULL, NULL, NULL, NULL, NULL),
('3101485552;2;ROCK CONSTRUCTIONS AND DEVELOPMENT SOCIEDAD ANONIMA;ROCK CONSTRUCTIONS S.A;CR;2001-07-02;0;3101727041;\";9;\";\";\";\";\";\";\";\";\";109780599;RICARDO LIZANO YGLESIAS;San José, Santa Ana;2;Ingeniero Civil;Ricardo Lizano Yglesias;25887900;info@rc.cr;San José, Santa Ana, del Más x Menos 200 norte y 50 este;0;P;\";\";\";0;0;0;2;0.0;images/3101485552.jpg;Somos una empresa constructora especializada en obras de infraestructura residencial y turistica de gran envergadura, tales como proyectos inmobiliarios y urbanizacion en general, los cuales se estan desarrollando actualmente a lo largo y ancho de Costa Rica.  Desde comienzos hemos sobrepasado nuestras expectativas como lideres en la construccion. Buscar el mejoramiento en la calidad de los productos y servicios que ofrecemos. Asi como una constante innovacion en nuevas practicas y sistemas en la construccion.;\";\";2018-07-11 22:12:27;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101493379;2;INVERSIONES MADRIQUE SOCIEDAD ANONIMA;INVERSIONES MADRIQUE S.A;CR;2010-07-19;0;3101727041;\";9;\";16101008310189489;\";\";\";\";\";\";\";303560702;LUIS DIEGO QUESADA MADRIGAL;Barrio Asís, Cartago;4;Economista;Luis Diego Quesada Madrigal;70705222;lmadrique@gmail.com;Barrio Asís, Cartago;0;P;\";\";\";0;0;0;2;0.0;images/3101493379.jpg;Inversiones Madrique S.A es una empresa costarricense que se dedica al negocio inmobiliario, con la administración y alquiler de edificios a diferentes instituciones.;\";\";2018-07-18 21:55:44;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101511598;2;Asesores Sysynfo S.A;Asesores Sysynfo S.A;cr;2018-02-28;1;1;0;0;0;0;0;\";\";\";\";\";\";106540792;Gerardo Antonio;N/R;1;0;N/R;Gerardo Antonio;gumana@asesoresysynfo.com;N/R;1;N;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-02-28 08:36:40;WEB', NULL, NULL, NULL, NULL, NULL),
('3101526083;1;INVERSIONES TIERRA NUESTRA DEL SOL  K Y M S.A.;TierraSOL;CR;2017-03-01;1;1;\";2;12300130007065011;12300130007065005;\";\";\";\";\";\";\";1-1008-0199;MANUEL CASTRO SANCHEZ;HEREDIA , SAN RAFAEL CALLE COLIBRI;2;ADMINISTRACIÓN DE EMPRESA, Costarricense, ;WALTER ESPINOZA;8821-5561;\";\";0;N;N;A;Costa Rica;0;0;0;0;1.0;\";\";\";\";2017-01-24 18:40:49;Gerson', NULL, NULL, NULL, NULL, NULL),
('3101560550;2;FLAMA AZUL DEL OESTE, S.A.;Flama_Azul;CR;2016-11-01;1;1;\";2;\";\";\";\";\";\";\";\";\";\";\";\";0;\";\";\";\";\";0;P;\";\";\";0;0;0;0;0.0;\";\";\";\";2016-11-25 13:45:18;gerson78', NULL, NULL, NULL, NULL, NULL),
('3101562914;2;RIVERING DE COSTA RICA S.A;RIVERING S.A;CR;2009-01-29;0;2147483647;\";9;\";15201001027259674;\";\";\";\";\";\";\";1-0811-0682;Julio Masís Jiménez;San José;2;Ingeniero;Marisol Masís Jiménez;2227-0631;rivering.cr@gmail.com;Barrio Los Sauces, San Francisco de Dos Ríos, San José;1;P;\";\";\";0;0;0;2;0.0;images/rivering.jpeg;Consultoría en el Área de la Ingeniería Civil y Ambiental. Especializados en las áreas de Diseño hidráulico e hidrológico de carreteras y puentes, diseño de sistemas de alcantarillados pluviales y sanitarios, diseño de sistemas de abastecimiento de agua potable (acueductos) , diseño de obras de protección contra inundaciones, diseño de obras de protección contra la erosión, diseño de obras de protección contra deslizamientos y avalanchas de lodos.  Además de estudios de vulnerabilidad y amenaza de origen hidrometeorológico, mapeo de zonas inundables. Desarrollamos estudios para protocolos de hidrología de SETENA, estudios de hidrología e hidráulica para permisos de desfogues y peritajes relacionados con hidrología, hidráulica, transporte de sedimentos y mecánica fluvial.;\";\";2018-03-06 21:15:56;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101586136;2;AUTO LAVADO LA PLAYA S.A ;AUTO LAVADO LA PLAYA S.A ;CR;2018-07-09;1;1;0;0;0;0;0;\";\";\";\";\";\";503100082;GERARDO  ;N/R;1;0;N/R;GERARDO  ;ventasmegalib@hotmail.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-07-09 08:01:34;WEB', NULL, NULL, NULL, NULL, NULL),
('3101593688;2;PapelDeco SA;PapelDeco;CR;2010-01-11;2;801070063;\";9;\";15121110010000511;\";\";\";\";\";\";\";1-1117-0611;Leonel Arturo González Higaldo;Heredia, Belén, La Asunción;2;Comerciante, Costarricense, ;Marilyn Morales;22391026;mmorales@teraconsultingcr.com;Heredia, Belén, La Asunción, Frente al Salón del Reino de los Testigos de Jehová;0;P;\";\";1;4;7;3;2;1.0;images/papeldeco.jpg;CompaNia que presenta una alternativa de soluciÃ³n a los requerimientos de las empresas, encargÃ¡ndonos de sus necesidades en suministros de limpieza e higiene, empaques flexibles y productos de papel en general de forma integral. <a href=\'http://papeldecocr.com/cms\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-07-12 18:19:48;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3101595167;2;Signature South Consulting Costa Rica S.A.;Signature South Consulting Costa Rica S.A.;CR;2018-03-22;1;1;0;0;0;0;0;\";\";\";\";\";\";111070740;Sergio ;N/R;1;0;N/R;Sergio ;sergio@chaverri.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-03-22 11:51:09;WEB', NULL, NULL, NULL, NULL, NULL),
('3101615701;2;SPINE CR S.A;SPINE;CR;2010-02-05;2;801070063;\";9;15116420025023282;15116420010048431;\";\";\";\";\";\";\";8-0093-0430;María Isabel Reyes Alvarez;San, José, Central, Hospital, del BCR 150 norte 100 este y 50 sur,;4;Administradora de Negocios, Costarricense, ;María Isabel Reyes Alvarez;88679323;gerencia@spinecr.com;San, José, Central, Hospital, del BCR 150 norte 100 este y 50 sur;0;P;N;A;1;1;1;3;2;0.0;images/spine_cr.png;Empresa que innova, diseña, fabrica y comercializa implantes e instrumental de uso quirúrgico para el tratamiento de patologías de columna vertebral.;\";\";2018-07-12 18:08:36;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3101624816;2;Servicios Administrativos e inmobiliarios J y H sociedad anonima;Inmob_JyH;CR;2010-12-07;1;1;\";2;\";\";\";\";\";\";\";\";\";1-1000-0050;Jeffry Gerardo Hernandez Corrales;San Jose;1;\";\";87127132;\";\";0;P;N;\";\";0;0;0;0;0.0;\";\";\";\";2016-12-07 16:49:35;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('310164051;2;THE BANK OF NOVA SCOTIA CR S.A;BNS;\";1921-02-01;0;2147483647;\";6;\";\";\";\";\";\";\";\";\";11004219;JUAN CARLOS VEGA VEGA;San Jose Uruca ;2;ADMINISTRACIÓN DE EMPRESAS;\";\";\";\";0;X;\";\";\";0;0;0;2;0.0;images/scotia_ico.png;El Grupo BNS de Costa Rica es una subsidiaria de The Bank of Nova Scotia. Ingresó a Costa Rica en 1995 ofreciendo al mercado nacional una amplia gama de productos y servicios financieros en sectores de Banca de Personas, Banca Comercial y Corporativa, Pymes, además de Fondos de Inversiones, Leasing, Seguros y Banca Privada ... <a href=\'http://www.scotiabank.com/ca/en/0,1091,5,00.html\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-01-05 16:30:48;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3101655669;2;Excelencia en Servicios IT y Outsourcing;Excelencia en Servicios IT y Outsourcing;CR;2018-06-24;1;1;0;0;0;0;0;\";\";\";\";\";\";204770156;Erick;N/R;1;0;N/R;Erick;erick.villalobos@excelteccr.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-06-24 15:45:06;WEB', NULL, NULL, NULL, NULL, NULL),
('3101670939;2;V-Net Comunicaciones S.A.;V-NET;CR;2014-05-15;0;801070063;\";9;15111910020001925;15111920010029671;\";\";\";\";\";\";\";186200221426;Jose Alejandro Hernandez Contreras;Condominio Fuerte Ventura casa #49, Pozos Santa Ana;2;Geologo;\";\";ahernandez@v-netcom.com;\";0;P;\";\";\";0;0;0;2;0.0;\\images\\ico_vnet.jpg;Empresa dedicada a la distribución de productos de telecomunicaciones en Costa Rica. Distribuidor y comercializador de los productos y servicios de kölbi CR. <a href=\'https://v-netcom.com/inicio/\' target=\'black\'> ( + info ) </a>;\";\";2018-05-28 17:59:22;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3101690116;2;Sinocem Costa Rica SA;Sinocem;CR;2014-12-02;1;801070063;\";6;CR66015118910020004127;CR87015118910010004698;\";\";\";\";\";\";\";205020049;Javier Rojas Segura;Alajuela, Grecia, 50 MTRS Oeste del Balneario Tropical;2;Administrador de empresas, Costarricense, ;Mario Cortes;22960082;mcortes@grupojcb.com;\";1;P;\";\";188;1;1;1;2;1.0;\";\";\";\";2018-03-14 22:47:53;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101697399;2;PROCONSA DE CONCRETO PROYECTOS CONSTRUCTIVOS JB SOCIEDAD ANONIMA;CONSTRUCTORA PROCONSA;CR;2015-02-03;1;2147483647;0;9;10200009240425670;10200009240425598;0;\";\";\";\";\";\";108790951;Ana Marcela Rodriguez Gonzalez;Condominio Río Palma  FF 63, Guachípelin, Escazú, San José;4;Politóloga-Economista;Ana Marcela Rodriguez Gonzalez;88540710;mrodriguez@proconsacr.com;Condominio Río Palma  FF 63, Guachípelin, Escazú, San José;1;P;N;\";CR;1;1;1;2;0.0;images/Proconsa logo.png;Proconsa S.A es una empresa de capital costarricense y cuenta con la experiencia comprobada en el sector de construcción de su equipo de ingenieros y técnicos, nuestros servicios están dirigidos al diseño y desarrollo de obras de construcción a nivel público y privado, residencias de medio y alto valor, remodelaciones, servicios de mantenimiento, obras exteriores y edificios.;\";\";2018-01-03 23:04:11;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101701112;2;ARMADILLO DISEÑO Y BTL S.A.;ARMADILLO;CR;2016-10-03;1;1;\";2;\";10200009243868735;\";\";\";\";\";\";\";8-0096-0844;MARITZA ORGANISTA DIAZ;MORAVIA DE TACOBELL 200OESTE 100 NORTE Y 100 OESTO;1;PUBLICISTA, Costarricense, ;MARITZA ORGANISTA;70104207;maritza@armadilloproducciones.com;moravia;0;P;\";A;Costa Rica;0;0;0;0;0.0;\";\";\";\";2017-01-27 22:09:47;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3101702806;2;PROPALLET, S.A.;PROPALLET, S.A.;CR;2015-07-17;1;2147483647;0;9;\";15103620010490148;0;\";\";\";\";\";\";111270525;Giovanni Rojas Vargas;De la Iglesia católica 500 este, casa de dos plantas color amarillo, San  Rafael, Vásquez de Coronado, San José;2;Comerciante;Randall Calvo Meléndez;8322-7786;randall.propallet@gmail.com;Río Segundo de Alajuela, antigua casa Phillipson;1;P;N;\";CR;1;1;1;2;0.0;\";Por más de 20 años ProPallet S.A. ha fabricado tarimas de madera y “Kits” los cuales son todas las partes que posee una tarima pero estas tienen la particularidad que se venden por separado y la empresa o cliente que las adquiera deben de armar las tarimas por ellos mismos. ;\";\";2018-03-05 22:04:44;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101710584;2;HCG COSTA RICA S.A;HCG;CR;2017-08-02;0;2147483647;\";6;\";\";\";\";\";\";\";\";\";11111111;Mario berrenechea;San jose;2;Administración ;\";\";\";\";0;P;\";\";\";0;0;0;0;0.0;\";\";\";\";2017-08-18 19:12:12;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3101714710;2;PARQUE INDUSTRIAL DE ZONA FRANCA CITY PLACE SOCIEDAD ANONIMA;CITY PLACE;CR;2013-11-01;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;P;\";\";\";0;0;0;2;0.0;images/citiplace_logo.png;City Place es uno de los desarrollos más innovadores de Rocca Portafolio Comercial. Corresponde al primer Town Center en Santa Ana, un proyecto urbano realmente contemporáneo...  <a href=\'http://www.cityplacecr.com/ \' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:34:55;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101714776;2;Princesadulce s.a;Princesadulce s.a;CR;2018-06-23;1;1;0;0;0;0;0;\";\";\";\";\";\";109230768;Ricardo ;N/R;1;0;N/R;Ricardo ;rrudin@princesadulce.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-06-23 21:17:37;WEB', NULL, NULL, NULL, NULL, NULL),
('3101719704;2;EQUIPOS TACTICOS Y DE RESCATE ETR S.A;EQUIPOS TACTICOS Y DE RESCATE;CR;2017-10-29;1;206440727;0;9;\";10200009290931510;0;\";\";\";\";\";\";109540130;Roy Enrique Cantillano González;Lomas de Ayarco, Curridabat, San José;2;Empresario;Roy Cantillano;88923613;roy@rcgimports.com;Merced, Central, San José. Calle 14, Avenida 8 y 10, 75 sur del Hospital Metropolitano;1;P;N;\";CR;1;1;1;2;0.0;\";Contamos con 11 años de experiencia en la importación de equipos de rescate, seguridad, herramientas para limpieza y ornato municipal así como camiones y todo lo que conlleva el mantenimiento de parques, jardines e instituciones gubernamentales y privadas para lo cual brindamos la asesoría y servicio en el campo comprometidos con el desarrollo ambiental y social de las zonas que impactamos con el afán de lograr el embellecimiento visual y estético sin comprometer la naturaleza.;\";\";2018-01-18 16:32:55;Elio Rojas Rojas', NULL, NULL, NULL, NULL, NULL),
('3101727041;2;Masterzon CR SA;Masterzon;CR;2016-10-24;1;109260511;\";8;1020009297439539;1020009297439462;\";\";\";\";\";\";\";109260511;Elio Rojas Rojas;San Jose, Curridabat, Canton Sanchez, de la casa de doña Lela 400SUR, 300OESTE, 100NORTE ;2;ECONOMISTA, Costarricense, ;Jose Rivas Ramirez;87408777;info@masterzon.com;Ctro Comercial Sabana Sur, #31;0;P;N;\";1;1;1;1;2;1.0;images/logo_oficial_celeste.png;\";\";\";2018-05-04 22:06:20;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('3101727694;2;Granja AvÃ­cola Organica de Tilaran ;Granja AvÃ­cola Organica de Tilaran ;CR;2018-03-10;1;1;0;0;0;0;0;\";\";\";\";\";\";303570865;Karol;N/R;1;0;N/R;Karol;karofh@icloud.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-03-10 19:40:31;WEB', NULL, NULL, NULL, NULL, NULL),
('3101736419;2;CIARRE BROKERAGE AND AVISORY SOCIEDAD ANONIMA;CIARRE BROKERAGE AND AVISORY S.A.;CR;2017-07-31;1;1;0;9;0;0;0;\";\";\";\";\";\";1830937;vICENTE;N/R;1;0;N/R;vICENTE;vicente.lines@ariaslaw.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2017-07-31 11:59:59;WEB', NULL, NULL, NULL, NULL, NULL),
('3102003210;2;LUTZ HERMANOS & COMPAÑIA LTDA.;YAMAHA CR;CR;2014-01-05;1;801070063;\";2;\";\";\";\";\";\";\";\";\";\";\";\";2;\";Diane Monge;22115923;dmonge@yamahacr.com;Uruca centro;0;P;\";\";\";0;0;0;0;0.0;\";\";\";\";2017-04-28 15:16:45;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3102347058;2;JONES LANG LASALLE, LTDA;JLL (MERCK);CR;1816-11-01;1;801070063;\";2;0;0;\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;P;\";\";\";0;0;0;1;0.0;images/jll.png;Una historia de dos ciudades y expansión global\nLa historia de JLL abarca más de 200 años, pero sólo haremos referencia a los momentos más destacados:....... <a href=\'http://www.latinamerica.jll.com/latin-america/es-ar/acerca-de-nosotros/historia-global\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-05-24 14:22:44;Jose Rivas', NULL, NULL, NULL, NULL, NULL),
('3102372096;2;PROMEDICAL DE COSTA RICA;PROMEDICAL;CR;2004-04-30;2;801070063;\";9;\";15101210010097023;\";\";\";\";\";\";\";1-1117-0611;Leonel Arturo González Higaldo;Heredia, Belén, La Asunción;2;Comerciante, Costarricense, ;Marilyn Morales;22391026;mmorales@teraconsultingcr.com;Heredia, Belén, La Asunción, Frente al Salón del Reino de los Testigos de Jehová;0;P;\";A;CR;4;7;3;2;1.0;images/ico.png;VENTA DE SUMINISTROS DE LIMPIEZA. <a href=\'https://www.facebook.com/pages/PROMEDICAL-de-Costa-Rica/141281502568818\' alt=\'+info\' height=\"25\" width=\"25\"/><img src=\'images/ICO.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-07-12 18:19:10;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('3102457983;2;Taller Industrial Rojas y Herrera Ltda;Taller Industrial Rojas y Herrera Ltda;CR;2018-07-09;1;1;0;0;0;0;0;\";\";\";\";\";\";155812716817;Juan Carlos ;N/R;1;0;N/R;Juan Carlos ;jherrera@gihcr.com;N/R;1;P;N;\";CR;1;1;1;1;0.0;\";\";\";\";2018-07-09 14:26:23;WEB', NULL, NULL, NULL, NULL, NULL),
('3102534789;2;LATIN AMERICAN CAPITAL LTDA;LAC;CR;2007-04-01;1;2147483647;\";11;CR21010402240510714626;CR23010402240510713911;\";\";\";\";\";\";\";109910421;Mary Liz Ramirez Cedeño;San José, Central, Uruca;2;Directora de Proyectos, Costarricense, ;Roberto Castillo;88331367;mramirez@lac.co.cr;San José, Central, Uruca, Del Hotel San José Palacio 400 al norte y 50 este;0;P;N;A;1;1;7;1;1;1.0;images/lac_ico.jpg;Latin American Capital S.R.L. conforma un conglomerado empresarial de carácter regional y multidisciplinario, que brinda servicios integrales para soluciones legales y financieras, seguras, ágiles, eficientes y confiables, utilizando una plataforma de inteligencia operativa legal y financiera innovadora, garantizando la eficacia y seguridad del tráfico de los recursos... <a href=\'http://lac.co.cr/\' alt=\'+info\' height=\"25\" width=\"25\"/><img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-01-18 16:37:18;Elio Rojas Rojas', NULL, NULL, NULL, NULL, NULL),
('3102635849;2;MATERIALES INDUSTRIALES INDUMA SRL;INDUMA;CR;2000-01-01;1;206440727;\";2;10200009125809748;10200009125809665;\";\";\";\";\";\";\";1-1161-0555;Diego Alonso Flores Porras;San José, Santa Ana, Santa Ana, 150 oeste de la Cruz Roja;1;Estudiante, Costarricense, ;Diego Alonso Flores Porras;71413922;fulate@masterzon.com;San José, Santa Ana, Santa Ana, 150 oeste de la Cruz Roja;0;P;\";A;CR;1;1;9;1;0.0;images/induma.png;Materiales Industriales Induma S.R.L.200mts Oeste de la Cruz Roja,diagonal al Colegio de Santa Ana,San José, Costa Rica <a href=\'https://sites.google.com/a/indumacr.com/www/\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a> ;\";\";2017-11-06 17:18:40;Gerson', NULL, NULL, NULL, NULL, NULL),
('3102698462;2;TECNOLOGIAS MEDICAS Y SISTEMAS, TECMEDISI;TECMEDISI;CR;2016-11-01;1;1;\";2;\";\";\";\";\";\";\";\";\";\";\";\";0;\";\";\";\";\";0;P;\";\";\";0;0;0;2;0.0;\";\";\";\";2016-11-25 13:45:18;gerson78', NULL, NULL, NULL, NULL, NULL),
('3102734076;2;ECHANDI, VARGAS Y ASOCIADOS SRL;ECHANDI, VARGAS;CR;2017-04-19;1;2147483647;\";2;\";15108710010019677;\";\";\";\";\";\";\";\";\";\";1;\";\";83024226;notariainternacional@gmail.com;\";0;P;\";\";188;1;1;1;1;1.0;\";\";\";\";2017-04-19 18:48:32;Gerson', NULL, NULL, NULL, NULL, NULL),
('3110672283;2;FIDEICOMISO BANCO NACIONAL-MINISTERIO DE EDUCACION PUBLICA  LEY No 9124;FIDEICOMISO BNCR-MEP ;\";2013-02-08;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/3110672283.png;Un fideicomiso suscrito entre el Ministerio de Educación Pública (MEP), Banco Interamericano de Desarrollo (BID) y Banco Nacional de Costa Rica (BNCR) con la intención de dotar de infraestructura educativa a 103 centros educativos entre el 2016 y 2018. Cuenta con un presupuesto de 167,5 millones de dólares. El fideicomiso fue producto de la Ley 9124, promulgada en el año 2013 y permitirá construir 79 escuelas y colegios, así como 29 canchas techadas.;\";\";2018-02-06 17:29:00;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('4000000019;2;BANCO DE COSTA RICA;BCR;CR;1877-04-20;1;801070063;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;N;\";188;1;1;1;1;1.0;images/logo-bcr.png;Nació con el propósito de ser una nueva opción bancaria entre las ya existentes y tuvo como funciones iniciales el prestar dinero, llevar cuentas corrientes, recibir depósitos y efectuar cobranzas, entre otras ... <a href=\'https://www.bancobcr.com/acerca%20del%20bcr/Historia.html\' alt=\'+info\' height=\"25\" width=\"25\"/><img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-02-15 21:22:15;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('4000001128;2;BANCO CREDITO AGRICOLA DE CARTAGO;BANCREDITO;CR;1918-07-01;0;801070063;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";1;1;1;1;1;1.0;images/logoBancredito.PNG;BancrEdito, en sus orÃ­genes fue una casa bancaria de carÃ¡cter regional, fundada para promover el desarrollo de la Provincia de Cartago, mediante el impulso de la agricultura, tradicionalmente la actividad econÃ³mica por excelencia en las fÃ©rtiles tierras cartaginesas......... <a href=\'https://www.bancreditocr.com/conozcanos/quienes_somos/\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-04-19 17:22:36;Gerson', NULL, NULL, NULL, NULL, NULL),
('4000001902;2;INSTITUTO NACIONAL DE SEGUROS;INS;\";1924-01-17;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/4000001902.gif;El Instituto Nacional de Seguros (INS) es una institución estatal de Costa Rica, la cual ofrece seguros y servicios relacionados a nivel nacional e internacional, además de promover la prevención de riesgos para el trabajo, el hogar y el tránsito de vehículos.;\";\";2018-01-17 17:51:53;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('4000004017;2;BANCO CENTRAL DE COSTA RICA;BCCR;\";1950-01-28;0;206440727;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/ico_bccr.jpeg;En 1948, al decretarse la nacionalización de la banca privada -recepción de depósitos del público - y dada la necesidad de dotar al nuevo Sistema Bancario Nacional de una integración orgánica adecuada y una orientación eficiente por parte del Estado, se hizo más urgente la necesidad de establecer el Banco Central como órgano independiente y rector de la política económica, monetaria y crediticia del país. Con este propósito se promulgó la Ley 1130. <a href=\'https://www.bccr.fi.cr/seccion-sobre-bccr/rese%C3%B1a-hist%C3%B3rica\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-09-07 21:34:12;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('4000042138;1;INSTITUTO COSTARRICENSE DE ACUEDUCTOS Y ALCANTARILLADOS; A Y A;CR;2017-05-07;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;N;\";\";\";0;0;0;0;0.0;\";\";\";\";2018-05-30 22:32:56;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('4000042139;2;INSTITUTO COSTARRICENSE DE ELECTRICIDAD;ICE;CR;1949-05-08;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/ICE.png;El Instituto Costarricense de Electricidad (ICE) fue creado por el Decreto - Ley No.449 del 8 de abril de 1949........ <a href=\'https://www.grupoice.com/wps/portal/ICE/AcercadelGrupoICE/quienes-somos/historia-del-ice\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:33:21;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('4000042143;2;INSTITUTO DE DESARROLLO RURAL;INDER;\";1962-10-25;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;0;0.0;\";El Inder tiene por origen al Instituto de Tierras y Colonización (ITCO), creado mediante Ley No. 2825 del 14 octubre de 1961, denominado por su naturaleza Ley de Tierras y Colonización, nace a la vida jurídica-administrativa mediante celebración de la primera sesión de Junta Directiva, el 25 de octubre de 1962.  Posteriormente, a través de la Ley No. 6735 del 29 marzo de 1982, se transforma el Instituto de Tierras y Colonización, en Instituto de Desarrollo Agrario (IDA), con las mismas prerrogativas constitutivas de la ley anterior (Artículo 1). Otra ley muy relacionada con la actividad ordinaria del Instituto es la Ley de Jurisdicción Agraria. Nº. 6734 del 25 de marzo de 1982. El 22 de marzo del 2012 la Asamblea Legislativa aprueba la Ley 9036, que transforma al Instituto de Desarrollo Agrario en el Instituto de Desarrollo Rural.;\";\";2018-05-30 22:33:50;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('4000042145;2;INSTITUTO TECNOLOGICO DE COSTA RICA;I.T.C.R;CR;1971-06-10;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/TEC.png;El TecnoLOgico de Costa Rica (TEC) es una instituciÃ³n nacional autÃ³noma de educaciÃ³n superior universitaria, dedicada a la docencia, la investigaciÃ³n y la extensiÃ³n de la tecnologÃ­a y las ciencias conexas para el desarrollo de Costa Rica. Fue creado mediante ley No. 4.777 del 10 de junio de 1971........ <a href=\'https://www.tec.ac.cr/que-es-tec\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:34:11;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('4000042147;2;CAJA COSTARRICENSE DE SEGURO SOCIAL;CCSS;CRC;1941-11-01;0;2147483647;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";6;X;\";G;188;1;101;10101;1;0.0;images/logoCCSS.png;1940; La Caja Costarricense de Seguro Social (CCSS) se crea como una Institución semiautónoma el 1 de noviembre de 1941 mediante Ley No. 17 durante la administración del Dr. Rafael Angel Calderón Guardia.........<a href=\'http://www.ccss.sa.cr/cultura#memorias\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-01-05 16:31:09;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('4000042149;2;UNIVERSIDAD DE COSTA RICA;UCR;\";1940-09-26;0;801070063;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/4000042149.png;La Universidad de Costa Rica es una institución de educación superior y cultura, autónoma constitucionalmente y democrática, constituida por una comunidad de profesores y profesoras, estudiantes y personal administrativo, dedicada a la enseñanza, la investigación, la acción social, el estudio, la meditación, la creación artística y la difusión del conocimiento.;\";\";2018-01-05 16:59:11;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('4000042150;2;UNIVERSIDAD NACIONAL;UNA;\";1973-02-15;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/4000042150.png;La Universidad Nacional de Costa Rica (UNA) es una universidad publica costarricense con gran prestigio a nivel nacional e internacional ademas de ser reconocida como una universidad dedicada a la investigacion y posicionada entre las mejores universidades a nivel mundial. Es una de las mejores universidades de la Republica de Costa Rica y America Latina. Segun el mas reciente estudio con base en los estandares internacionales utilizados para evaluar a las universidades, la Universidad Nacional de Costa Rica ocupa el lugar numero 55 en America Latina y el 701 a nivel mundial.;\";\";2018-05-21 18:34:32;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `TABLE 37` (`COL 1`, `COL 2`, `COL 3`, `COL 4`, `COL 5`, `COL 6`) VALUES
('4000042151;2;UNIVERSIDAD ESTATAL A DISTANCIA;UNED;\";1977-01-03;0;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/4000042151.png;La Universidad Estatal a Distancia (UNED), es una de las cinco universidades públicas de Costa Rica. Se encuentra ubicada en Sabanilla, Montes de Oca, de modalidad a distancia, es la segunda universidad en cantidad de estudiantes; y es la de mayor cobertura en el país. Posee además su propia editorial que produce una gran variedad tanto de libros de texto que cubren la mayor parte de las necesidades de la universidad, como de obras ensayísticas, de investigación, etc. Esta institución fue creada en 1977.;\";\";2018-01-24 18:37:40;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('4000042152;2;BANCO POPULAR Y DE DESARROLLO COMUNAL;BANCO POPULAR;CR;1969-07-11;1;2147483647;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/banco-popular.png;1901: El Banco Popular surge de la iniciativa de transformar un fondo de ahorro capitalizado, llamado El Monte de la Piedad, dedicado a pignorar alhajas y prendas para solventar las necesidades urgentes de los trabajadores…<a href=\'https://www.bancopopular.fi.cr/BPOP/Nosotros/Historia.aspx\' target=\'black\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-01-05 16:30:15;Rafael Villalobos', NULL, NULL, NULL, NULL, NULL),
('4000045127;2;INSTITUTO NACIONAL DE APRENDIZAJE;I.N.A.;CR;1965-05-21;1;2147483647;\";0;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";\";0;0;0;1;0.0;images/ina.png;El Instituto Nacional de Aprendizaje (INA) es una entidad autónoma creada por la ley No.3506 del 21 de mayo de 1965, reformada por su Ley Orgánica No. 6868 del 6 de mayo de 1983.  Su principal tarea es promover y desarrollar la capacitación y formación profesional de los hombres y mujeres en todos los sectores de la producción para....... <a href=\'http://www.ina.ac.cr/faq/\'> <img src=\'images/info_signo.png\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2018-05-30 22:34:37;Francisco Ulate Azofeifa', NULL, NULL, NULL, NULL, NULL),
('4000100021;2;BANCO NACIONAL DE COSTA RICA;B.N.C.R.;cr;1914-10-09;1;2147483647;\";2;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;X;\";\";1;1;1;1;1;1.0;images/logoBNCR.png;El Banco Nacional nació en 1914, al iniciarse la Administración del presidente Alfredo González Flores. En aquel momento comenzaba también la I Guerra Mundial. Previendo una posible contracción de las exportaciones, el Gobierno requería estimular la demanda interna..... <a href=\'https://www.bncr.fi.cr/BNCR/Conozcanos/Historia.aspx\' alt=\'+info\' height=\"25\" width=\"25\"/></a>;\";\";2017-06-27 21:34:50;Gerson', NULL, NULL, NULL, NULL, NULL),
('602240460;1;William Chen Mok;William Chen Mok;CR;2017-06-04;1;801070063;\";2;10200007196460020;\";\";\";\";\";\";\";\";602240460;\";\";1;\";\";\";tortolon69@gmail.com;\";0;N;\";\";\";0;0;0;0;0.0;\";\";\";\";2017-08-18 15:27:07;Gerson', NULL, NULL, NULL, NULL, NULL),
('800820648;1;Christopher Norman;Cris Norman;EEUU;2017-07-05;0;801070063;\";6;\";\";\";\";\";\";\";\";\";\";\";\";1;\";\";\";\";\";0;N;\";\";\";0;0;0;0;0.0;\";\";\";\";2017-07-05 18:48:40;Gerson', NULL, NULL, NULL, NULL, NULL),
('801070063;1;Cesar Peralta;Cesar;cr;2017-02-16;1;801070063;\";2;\";\";\";\";\";\";\";\";\";\";\";\";4;\";Cesar Peralta;71032778;cperaltah@gmail.com;\";0;N;\";\";\";0;0;0;0;0.0;\";\";\";\";2017-02-16 20:21:15;Gerson', NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tblreseteopass`
--

CREATE TABLE `tblreseteopass` (
  `id` int(10) UNSIGNED NOT NULL,
  `idusuario` int(10) UNSIGNED NOT NULL,
  `username` varchar(15) COLLATE latin1_spanish_ci NOT NULL,
  `token` varchar(64) COLLATE latin1_spanish_ci NOT NULL,
  `creado` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Dumping data for table `tblreseteopass`
--

INSERT INTO `tblreseteopass` (`id`, `idusuario`, `username`, `token`, `creado`) VALUES
(128, 1783445, 'fsoto', '49377fd4c1a1cb8d216131a1ea9725bd0f38059f', '2018-04-10 21:02:37'),
(129, 4294967295, 'msatger', '98687027f04a6ab467fa4cb98d47493d5d7aaf2b', '2018-06-07 21:46:45');

-- --------------------------------------------------------

--
-- Table structure for table `tmp_partes_contrato`
--

CREATE TABLE `tmp_partes_contrato` (
  `des_seccion_completa` varchar(8000) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `cod_seccion` int(5) DEFAULT NULL,
  `num_operacion` varchar(50) DEFAULT NULL,
  `num_identificacion` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tmp_partes_factura_estandar`
--

CREATE TABLE `tmp_partes_factura_estandar` (
  `des_seccion_completa` varchar(8000) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `cod_seccion` int(5) DEFAULT NULL,
  `num_operacion` varchar(50) DEFAULT NULL,
  `num_identificacion` varchar(50) DEFAULT NULL,
  `can_fracciones` int(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tmp_partes_letra_cambio`
--

CREATE TABLE `tmp_partes_letra_cambio` (
  `des_seccion_completa` varchar(8000) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `cod_seccion` int(5) DEFAULT NULL,
  `num_operacion` varchar(50) DEFAULT NULL,
  `num_identificacion` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `grf_orden_dashboard_factoring`
--
ALTER TABLE `grf_orden_dashboard_factoring`
  ADD PRIMARY KEY (`cod_grafico`,`num_operacion`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `password_resets_email_index` (`email`),
  ADD KEY `password_resets_token_index` (`token`);

--
-- Indexes for table `sis_bitacora_accesos`
--
ALTER TABLE `sis_bitacora_accesos`
  ADD PRIMARY KEY (`fec_hora_acceso`,`cod_usuario`);

--
-- Indexes for table `sis_bitacora_eventos`
--
ALTER TABLE `sis_bitacora_eventos`
  ADD PRIMARY KEY (`num_consecutivo`);

--
-- Indexes for table `sis_calces_captaciones`
--
ALTER TABLE `sis_calces_captaciones`
  ADD PRIMARY KEY (`cod_calce_captacion`);

--
-- Indexes for table `sis_calces_captaciones_pymes`
--
ALTER TABLE `sis_calces_captaciones_pymes`
  ADD PRIMARY KEY (`cod_calce_captacion`);

--
-- Indexes for table `sis_catalogo_instrumentos`
--
ALTER TABLE `sis_catalogo_instrumentos`
  ADD PRIMARY KEY (`cod_instrumento`);

--
-- Indexes for table `sis_catalogo_juridicos`
--
ALTER TABLE `sis_catalogo_juridicos`
  ADD PRIMARY KEY (`num_identificacion`,`cod_tipo_identificacion`),
  ADD KEY `fk_CatJuridicos` (`cod_tipo_membresia`);

--
-- Indexes for table `sis_catalogo_membresias`
--
ALTER TABLE `sis_catalogo_membresias`
  ADD PRIMARY KEY (`cod_tipo_membresia`);

--
-- Indexes for table `sis_datos_tmp_contratos`
--
ALTER TABLE `sis_datos_tmp_contratos`
  ADD PRIMARY KEY (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`);

--
-- Indexes for table `sis_datos_tmp_factura_estandar`
--
ALTER TABLE `sis_datos_tmp_factura_estandar`
  ADD PRIMARY KEY (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`);

--
-- Indexes for table `sis_datos_tmp_letras_cambio`
--
ALTER TABLE `sis_datos_tmp_letras_cambio`
  ADD PRIMARY KEY (`num_identificacion`,`num_operacion`,`cod_seccion`,`cod_variable`);

--
-- Indexes for table `sis_ejecutivos`
--
ALTER TABLE `sis_ejecutivos`
  ADD PRIMARY KEY (`num_cedula`);

--
-- Indexes for table `sis_emisiones`
--
ALTER TABLE `sis_emisiones`
  ADD PRIMARY KEY (`cod_emision`);

--
-- Indexes for table `sis_emisiones_privadas`
--
ALTER TABLE `sis_emisiones_privadas`
  ADD PRIMARY KEY (`cod_emision`);

--
-- Indexes for table `sis_estados_operaciones`
--
ALTER TABLE `sis_estados_operaciones`
  ADD PRIMARY KEY (`cod_estado`);

--
-- Indexes for table `sis_estado_civil`
--
ALTER TABLE `sis_estado_civil`
  ADD PRIMARY KEY (`cod_estado_civil`);

--
-- Indexes for table `sis_feriados`
--
ALTER TABLE `sis_feriados`
  ADD PRIMARY KEY (`cod_feriado`);

--
-- Indexes for table `sis_fuentes_tc_monedas`
--
ALTER TABLE `sis_fuentes_tc_monedas`
  ADD PRIMARY KEY (`cod_fuente_tc`);

--
-- Indexes for table `sis_notificaciones_sms`
--
ALTER TABLE `sis_notificaciones_sms`
  ADD PRIMARY KEY (`cod_notificacion`);

--
-- Indexes for table `sis_obs_operaciones_factoring`
--
ALTER TABLE `sis_obs_operaciones_factoring`
  ADD PRIMARY KEY (`num_operacion`);

--
-- Indexes for table `sis_operaciones_cooperativas`
--
ALTER TABLE `sis_operaciones_cooperativas`
  ADD PRIMARY KEY (`num_operacion`,`cod_tipo_factura`,`cod_vendedor`);

--
-- Indexes for table `sis_operaciones_pymes`
--
ALTER TABLE `sis_operaciones_pymes`
  ADD PRIMARY KEY (`num_operacion`,`cod_vendedor`);

--
-- Indexes for table `sis_parametros`
--
ALTER TABLE `sis_parametros`
  ADD PRIMARY KEY (`cod_parametro`);

--
-- Indexes for table `sis_pujas_operaciones`
--
ALTER TABLE `sis_pujas_operaciones`
  ADD PRIMARY KEY (`cod_puja_operacion`);

--
-- Indexes for table `sis_pujas_operaciones_hist`
--
ALTER TABLE `sis_pujas_operaciones_hist`
  ADD PRIMARY KEY (`cod_puja_operacion`);

--
-- Indexes for table `sis_pujas_operaciones_privadas`
--
ALTER TABLE `sis_pujas_operaciones_privadas`
  ADD PRIMARY KEY (`cod_puja_operacion`);

--
-- Indexes for table `sis_pujas_operaciones_privadas_hist`
--
ALTER TABLE `sis_pujas_operaciones_privadas_hist`
  ADD PRIMARY KEY (`cod_puja_operacion`);

--
-- Indexes for table `sis_secciones_contratos`
--
ALTER TABLE `sis_secciones_contratos`
  ADD PRIMARY KEY (`cod_tipo_contrato`,`cod_seccion_contrato`);

--
-- Indexes for table `sis_tipos_contratos`
--
ALTER TABLE `sis_tipos_contratos`
  ADD PRIMARY KEY (`cod_tipo_contrato`);

--
-- Indexes for table `sis_tipos_identificaciones`
--
ALTER TABLE `sis_tipos_identificaciones`
  ADD PRIMARY KEY (`cod_tipo_identificacion`);

--
-- Indexes for table `sis_tipos_monedas`
--
ALTER TABLE `sis_tipos_monedas`
  ADD PRIMARY KEY (`cod_tipo_moneda`);

--
-- Indexes for table `sis_tipos_periodicidades`
--
ALTER TABLE `sis_tipos_periodicidades`
  ADD PRIMARY KEY (`cod_tipo_periodicidad`);

--
-- Indexes for table `sis_tipos_sectores`
--
ALTER TABLE `sis_tipos_sectores`
  ADD PRIMARY KEY (`cod_sector`);

--
-- Indexes for table `sis_tipo_cambio_monedas`
--
ALTER TABLE `sis_tipo_cambio_monedas`
  ADD PRIMARY KEY (`fec_tipo_cambio`,`cod_moneda`,`cod_fuente`);

--
-- Indexes for table `sis_usuarios`
--
ALTER TABLE `sis_usuarios`
  ADD PRIMARY KEY (`cod_usuario`),
  ADD UNIQUE KEY `num_identificacion` (`num_identificacion`);

--
-- Indexes for table `sis_variables_secciones`
--
ALTER TABLE `sis_variables_secciones`
  ADD PRIMARY KEY (`cod_contrato`,`cod_seccion`,`cod_variable`);

--
-- Indexes for table `tblreseteopass`
--
ALTER TABLE `tblreseteopass`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idusuario` (`idusuario`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `grf_orden_dashboard_factoring`
--
ALTER TABLE `grf_orden_dashboard_factoring`
  MODIFY `cod_grafico` int(3) NOT NULL AUTO_INCREMENT COMMENT 'Indica el codigo del grafico a desplegar ';

--
-- AUTO_INCREMENT for table `sis_bitacora_eventos`
--
ALTER TABLE `sis_bitacora_eventos`
  MODIFY `num_consecutivo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=309;

--
-- AUTO_INCREMENT for table `sis_calces_captaciones`
--
ALTER TABLE `sis_calces_captaciones`
  MODIFY `cod_calce_captacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sis_calces_captaciones_pymes`
--
ALTER TABLE `sis_calces_captaciones_pymes`
  MODIFY `cod_calce_captacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `sis_catalogo_membresias`
--
ALTER TABLE `sis_catalogo_membresias`
  MODIFY `cod_tipo_membresia` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `sis_emisiones`
--
ALTER TABLE `sis_emisiones`
  MODIFY `cod_emision` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sis_emisiones_privadas`
--
ALTER TABLE `sis_emisiones_privadas`
  MODIFY `cod_emision` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `sis_estados_operaciones`
--
ALTER TABLE `sis_estados_operaciones`
  MODIFY `cod_estado` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `sis_estado_civil`
--
ALTER TABLE `sis_estado_civil`
  MODIFY `cod_estado_civil` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `sis_feriados`
--
ALTER TABLE `sis_feriados`
  MODIFY `cod_feriado` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `sis_fuentes_tc_monedas`
--
ALTER TABLE `sis_fuentes_tc_monedas`
  MODIFY `cod_fuente_tc` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `sis_notificaciones_sms`
--
ALTER TABLE `sis_notificaciones_sms`
  MODIFY `cod_notificacion` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `sis_operaciones_cooperativas`
--
ALTER TABLE `sis_operaciones_cooperativas`
  MODIFY `num_operacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sis_operaciones_pymes`
--
ALTER TABLE `sis_operaciones_pymes`
  MODIFY `num_operacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `sis_pujas_operaciones`
--
ALTER TABLE `sis_pujas_operaciones`
  MODIFY `cod_puja_operacion` int(15) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sis_pujas_operaciones_hist`
--
ALTER TABLE `sis_pujas_operaciones_hist`
  MODIFY `cod_puja_operacion` int(15) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sis_pujas_operaciones_privadas`
--
ALTER TABLE `sis_pujas_operaciones_privadas`
  MODIFY `cod_puja_operacion` int(15) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `sis_pujas_operaciones_privadas_hist`
--
ALTER TABLE `sis_pujas_operaciones_privadas_hist`
  MODIFY `cod_puja_operacion` int(15) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `sis_tipos_contratos`
--
ALTER TABLE `sis_tipos_contratos`
  MODIFY `cod_tipo_contrato` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `sis_tipos_monedas`
--
ALTER TABLE `sis_tipos_monedas`
  MODIFY `cod_tipo_moneda` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `sis_tipos_periodicidades`
--
ALTER TABLE `sis_tipos_periodicidades`
  MODIFY `cod_tipo_periodicidad` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `tblreseteopass`
--
ALTER TABLE `tblreseteopass`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=130;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `sis_catalogo_juridicos`
--
ALTER TABLE `sis_catalogo_juridicos`
  ADD CONSTRAINT `fk_CatJuridicos` FOREIGN KEY (`cod_tipo_membresia`) REFERENCES `sis_catalogo_membresias` (`cod_tipo_membresia`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
