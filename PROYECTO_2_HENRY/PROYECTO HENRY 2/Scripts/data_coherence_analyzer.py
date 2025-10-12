#!/usr/bin/env python3
"""
ANALIZADOR DE COHERENCIA DE DATOS - FLEETLOGIX
==============================================

Script para detectar inconsistencias en los datos generados:
1. Nombres de género inconsistente (nombre femenino + segundo nombre masculino)
2. IDs huérfanos en relaciones entre tablas
3. Inconsistencias temporales (fechas imposibles)
4. Duplicados y datos ilógicos
5. Reporte consolidado con sugerencias de corrección

Autor: Alexis Jacquet
Fecha: Septiembre 2025
"""

import psycopg2
import pandas as pd
import logging
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv
import json
import sys

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('data_coherence_analysis.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class DataCoherenceAnalyzer:
    """Analizador de coherencia de datos para FleetLogix."""
    
    def __init__(self):
        """Inicializa el analizador."""
        load_dotenv()
        self.connection = None
        self.connect_db()
        
        # Listas de nombres por género para validación (AMPLIADAS)
        self.nombres_femeninos = {
            # Nombres tradicionales españoles
            'María', 'Ana', 'Carmen', 'Isabel', 'Dolores', 'Pilar', 'Teresa', 'Rosa', 'Francisca', 'Antonia',
            'Mercedes', 'Josefa', 'Concepción', 'Manuela', 'Juana', 'Elena', 'Cristina', 'Amparo', 'Montserrat',
            'Victoria', 'Patricia', 'Laura', 'Beatriz', 'Silvia', 'Mónica', 'Sandra', 'Natalia', 'Rocío',
            'Alejandra', 'Esperanza', 'Remedios', 'Encarnación', 'Nieves', 'Consuelo', 'Inmaculada',
            # Nombres modernos latinoamericanos/argentinos
            'Sofia', 'Sofía', 'Bianca', 'Luana', 'Isabella', 'Delfina', 'Josefina', 'Valentina', 'Julia', 
            'Felicitas', 'Milagros', 'Mia', 'Emma', 'Olivia', 'Martina', 'Catalina', 'Emilia', 'Camila',
            'Lucía', 'Renata', 'Antonella', 'Constanza', 'Agustina', 'Guadalupe', 'Julieta', 'Florencia',
            'Belén', 'Belen', 'Victoria'
        }
        
        self.nombres_masculinos = {
            # Nombres tradicionales españoles
            'Antonio', 'José', 'Manuel', 'Francisco', 'Juan', 'David', 'Miguel', 'Ángel', 'Carlos', 'Alejandro',
            'Daniel', 'Adrián', 'Pablo', 'Álvaro', 'Sergio', 'Diego', 'Mario', 'Jorge', 'Roberto', 'Fernando',
            'Jesús', 'Javier', 'Rafael', 'Andrés', 'Iván', 'Raúl', 'Eduardo', 'Alberto', 'Luis', 'Marcos',
            'Ricardo', 'Pedro', 'Santiago', 'Gonzalo', 'Víctor', 'Rubén', 'Óscar', 'Guillermo',
            # Nombres modernos latinoamericanos/argentinos
            'Santino', 'Valentino', 'Dylan', 'Lucio', 'Benjamin', 'Benjamín', 'Santiago', 'Ignacio', 'Thiago',
            'Lautaro', 'Luca', 'Jeremias', 'Jeremiah', 'Salvador', 'Mateo', 'Sebastián', 'Nicolás', 'Nicolas',
            'Gabriel', 'Lionel', 'Tomás', 'Agustín', 'Facundo', 'Felipe', 'Joaquín', 'Bruno', 'Máximo'
        }
        
        self.analysis_results = {
            'timestamp': datetime.now().isoformat(),
            'gender_inconsistencies': [],
            'referential_integrity_errors': [],
            'temporal_inconsistencies': [],
            'logical_errors': [],
            'summary': {}
        }
    
    def connect_db(self):
        """Conecta a la base de datos."""
        try:
            self.connection = psycopg2.connect(
                host='localhost',
                database='fleetlogix',
                user=os.getenv('DB_USER'),
                password=os.getenv('DB_PASSWORD')
            )
            logger.info("Conexión establecida con la base de datos")
        except Exception as e:
            logger.error(f"Error conectando a la base de datos: {e}")
            sys.exit(1)
    
    def analyze_gender_inconsistencies(self):
        """
        Detecta inconsistencias de género en nombres de conductores.
        Busca casos donde el primer nombre es de un género y el segundo de otro.
        """
        logger.info("ANALIZANDO INCONSISTENCIAS DE GÉNERO EN NOMBRES...")
        
        cursor = self.connection.cursor()
        try:
            # Obtener todos los conductores con nombres completos
            cursor.execute("""
                SELECT driver_id, first_name, last_name, phone
                FROM drivers
                WHERE first_name IS NOT NULL AND last_name IS NOT NULL
            """)
            
            drivers = cursor.fetchall()
            inconsistencies = []
            
            for driver_id, first_name, last_name, phone in drivers:
                # Dividir el first_name para obtener primer y segundo nombre
                name_parts = first_name.strip().split()
                
                if len(name_parts) >= 2:
                    primer_nombre = name_parts[0]
                    segundo_nombre = name_parts[1]
                    
                    # Verificar inconsistencias
                    primer_es_femenino = primer_nombre in self.nombres_femeninos
                    primer_es_masculino = primer_nombre in self.nombres_masculinos
                    segundo_es_femenino = segundo_nombre in self.nombres_femeninos
                    segundo_es_masculino = segundo_nombre in self.nombres_masculinos
                    
                    # Detectar inconsistencia: primer nombre de un género, segundo de otro
                    if (primer_es_femenino and segundo_es_masculino) or (primer_es_masculino and segundo_es_femenino):
                        inconsistency = {
                            'driver_id': driver_id,
                            'first_name': first_name,
                            'last_name': last_name,
                            'phone': phone,
                            'primer_nombre': primer_nombre,
                            'segundo_nombre': segundo_nombre,
                            'problema': f"Primer nombre {'femenino' if primer_es_femenino else 'masculino'}, segundo nombre {'femenino' if segundo_es_femenino else 'masculino'}",
                            'severidad': 'MEDIA'
                        }
                        inconsistencies.append(inconsistency)
            
            self.analysis_results['gender_inconsistencies'] = inconsistencies
            logger.info(f"Encontradas {len(inconsistencies)} inconsistencias de género")
            
            # Log de ejemplos
            for i, inc in enumerate(inconsistencies[:5]):  # Mostrar primeros 5
                logger.warning(f"  {i+1}. Driver {inc['driver_id']}: {inc['primer_nombre']} {inc['segundo_nombre']} - {inc['problema']}")
            
            if len(inconsistencies) > 5:
                logger.info(f"  ... y {len(inconsistencies) - 5} más")
                
        except Exception as e:
            logger.error(f"Error analizando géneros: {e}")
        finally:
            cursor.close()
    
    def analyze_gender_distribution(self):
        """
        Analiza la distribución de géneros en la base de datos completa.
        Detecta si hay mezcla inadecuada de nombres masculinos y femeninos.
        """
        logger.info("ANALIZANDO DISTRIBUCIÓN DE GÉNEROS EN LA BASE...")
        
        cursor = self.connection.cursor()
        try:
            # Obtener TODOS los nombres de conductores
            cursor.execute("SELECT driver_id, first_name FROM drivers")
            all_drivers = cursor.fetchall()
            
            masculinos = []
            femeninos = []
            no_identificados = []
            
            for driver_id, first_name in all_drivers:
                # Obtener primer nombre (antes del primer espacio)
                primer_nombre = first_name.split()[0] if first_name else ""
                
                if primer_nombre in self.nombres_masculinos:
                    masculinos.append((driver_id, first_name, primer_nombre))
                elif primer_nombre in self.nombres_femeninos:
                    femeninos.append((driver_id, first_name, primer_nombre))
                else:
                    no_identificados.append((driver_id, first_name, primer_nombre))
            
            # Agregar resultados al análisis
            gender_analysis = {
                'total_drivers': len(all_drivers),
                'masculinos': {
                    'count': len(masculinos),
                    'percentage': len(masculinos) / len(all_drivers) * 100,
                    'ejemplos': masculinos[:10]  # Primeros 10 ejemplos
                },
                'femeninos': {
                    'count': len(femeninos),
                    'percentage': len(femeninos) / len(all_drivers) * 100,
                    'ejemplos': femeninos[:10]  # Primeros 10 ejemplos
                },
                'no_identificados': {
                    'count': len(no_identificados),
                    'percentage': len(no_identificados) / len(all_drivers) * 100,
                    'ejemplos': no_identificados[:10]  # Primeros 10 ejemplos
                }
            }
            
            self.analysis_results['gender_distribution'] = gender_analysis
            
            # Log detallado
            logger.info("DISTRIBUCIÓN DE GÉNEROS:")
            logger.info(f"  Total conductores: {len(all_drivers)}")
            logger.info(f"  Nombres MASCULINOS: {len(masculinos)} ({len(masculinos)/len(all_drivers)*100:.1f}%)")
            logger.info(f"  Nombres FEMENINOS: {len(femeninos)} ({len(femeninos)/len(all_drivers)*100:.1f}%)")
            logger.info(f"  NO IDENTIFICADOS: {len(no_identificados)} ({len(no_identificados)/len(all_drivers)*100:.1f}%)")
            
            # Mostrar ejemplos
            if masculinos:
                logger.info(f"  Ejemplos masculinos: {', '.join([name for _, name, _ in masculinos[:5]])}")
            if femeninos:
                logger.info(f"  Ejemplos femeninos: {', '.join([name for _, name, _ in femeninos[:5]])}")
            if no_identificados:
                logger.info(f"  No identificados: {', '.join([name for _, name, _ in no_identificados[:5]])}")
                
            # Detectar si hay mezcla problemática
            if len(masculinos) > 0 and len(femeninos) > 0:
                logger.warning("PROBLEMA: Se detecta MEZCLA DE GÉNEROS en los nombres")
                logger.warning("La consigna especificaba usar nombres específicos españoles, no generación aleatoria")
                
                # Agregar como inconsistencia
                gender_mix_issue = {
                    'tipo': 'mezcla_generos_general',
                    'problema': f"Base de datos contiene {len(masculinos)} nombres masculinos y {len(femeninos)} nombres femeninos mezclados",
                    'severidad': 'MEDIA',
                    'recomendacion': 'Usar solo nombres específicos según consigna o mantener consistencia de género'
                }
                self.analysis_results['gender_inconsistencies'].append(gender_mix_issue)
                
        except Exception as e:
            logger.error(f"Error analizando distribución de géneros: {e}")
        finally:
            cursor.close()
    
    def analyze_referential_integrity(self):
        """
        Verifica integridad referencial completa entre todas las tablas.
        Busca IDs que no existen en las tablas padre.
        """
        logger.info("ANALIZANDO INTEGRIDAD REFERENCIAL...")
        
        cursor = self.connection.cursor()
        referential_errors = []
        
        try:
            # 1. Trips con vehicle_id inexistente
            cursor.execute("""
                SELECT t.trip_id, t.vehicle_id
                FROM trips t
                LEFT JOIN vehicles v ON t.vehicle_id = v.vehicle_id
                WHERE v.vehicle_id IS NULL
            """)
            orphan_trips_vehicles = cursor.fetchall()
            
            for trip_id, vehicle_id in orphan_trips_vehicles:
                referential_errors.append({
                    'tabla': 'trips',
                    'registro_id': trip_id,
                    'campo_fk': 'vehicle_id',
                    'valor_fk': vehicle_id,
                    'tabla_padre': 'vehicles',
                    'problema': f"trip_id {trip_id} referencia vehicle_id {vehicle_id} que no existe",
                    'severidad': 'ALTA'
                })
            
            # 2. Trips con driver_id inexistente
            cursor.execute("""
                SELECT t.trip_id, t.driver_id
                FROM trips t
                LEFT JOIN drivers d ON t.driver_id = d.driver_id
                WHERE d.driver_id IS NULL
            """)
            orphan_trips_drivers = cursor.fetchall()
            
            for trip_id, driver_id in orphan_trips_drivers:
                referential_errors.append({
                    'tabla': 'trips',
                    'registro_id': trip_id,
                    'campo_fk': 'driver_id',
                    'valor_fk': driver_id,
                    'tabla_padre': 'drivers',
                    'problema': f"trip_id {trip_id} referencia driver_id {driver_id} que no existe",
                    'severidad': 'ALTA'
                })
            
            # 3. Trips con route_id inexistente
            cursor.execute("""
                SELECT t.trip_id, t.route_id
                FROM trips t
                LEFT JOIN routes r ON t.route_id = r.route_id
                WHERE r.route_id IS NULL
            """)
            orphan_trips_routes = cursor.fetchall()
            
            for trip_id, route_id in orphan_trips_routes:
                referential_errors.append({
                    'tabla': 'trips',
                    'registro_id': trip_id,
                    'campo_fk': 'route_id',
                    'valor_fk': route_id,
                    'tabla_padre': 'routes',
                    'problema': f"trip_id {trip_id} referencia route_id {route_id} que no existe",
                    'severidad': 'ALTA'
                })
            
            # 4. Deliveries con trip_id inexistente
            cursor.execute("""
                SELECT d.delivery_id, d.trip_id
                FROM deliveries d
                LEFT JOIN trips t ON d.trip_id = t.trip_id
                WHERE t.trip_id IS NULL
            """)
            orphan_deliveries = cursor.fetchall()
            
            for delivery_id, trip_id in orphan_deliveries:
                referential_errors.append({
                    'tabla': 'deliveries',
                    'registro_id': delivery_id,
                    'campo_fk': 'trip_id',
                    'valor_fk': trip_id,
                    'tabla_padre': 'trips',
                    'problema': f"delivery_id {delivery_id} referencia trip_id {trip_id} que no existe",
                    'severidad': 'ALTA'
                })
            
            # 5. Maintenance con vehicle_id inexistente
            cursor.execute("""
                SELECT m.maintenance_id, m.vehicle_id
                FROM maintenance m
                LEFT JOIN vehicles v ON m.vehicle_id = v.vehicle_id
                WHERE v.vehicle_id IS NULL
            """)
            orphan_maintenance = cursor.fetchall()
            
            for maintenance_id, vehicle_id in orphan_maintenance:
                referential_errors.append({
                    'tabla': 'maintenance',
                    'registro_id': maintenance_id,
                    'campo_fk': 'vehicle_id',
                    'valor_fk': vehicle_id,
                    'tabla_padre': 'vehicles',
                    'problema': f"maintenance_id {maintenance_id} referencia vehicle_id {vehicle_id} que no existe",
                    'severidad': 'ALTA'
                })
            
            self.analysis_results['referential_integrity_errors'] = referential_errors
            logger.info(f"Encontrados {len(referential_errors)} errores de integridad referencial")
            
            # Log de errores por tabla
            if referential_errors:
                error_counts = {}
                for error in referential_errors:
                    tabla = error['tabla']
                    error_counts[tabla] = error_counts.get(tabla, 0) + 1
                
                for tabla, count in error_counts.items():
                    logger.error(f"  {tabla}: {count} errores de integridad")
            else:
                logger.info("  ✓ INTEGRIDAD REFERENCIAL: PERFECTA")
                
        except Exception as e:
            logger.error(f"Error analizando integridad referencial: {e}")
        finally:
            cursor.close()
    
    def analyze_temporal_inconsistencies(self):
        """
        Detecta inconsistencias temporales en fechas.
        """
        logger.info("ANALIZANDO INCONSISTENCIAS TEMPORALES...")
        
        cursor = self.connection.cursor()
        temporal_errors = []
        
        try:
            # 1. Viajes con llegada antes que salida
            cursor.execute("""
                SELECT trip_id, departure_datetime, arrival_datetime
                FROM trips
                WHERE arrival_datetime IS NOT NULL 
                AND arrival_datetime <= departure_datetime
            """)
            invalid_trips = cursor.fetchall()
            
            for trip_id, departure, arrival in invalid_trips:
                temporal_errors.append({
                    'tabla': 'trips',
                    'registro_id': trip_id,
                    'campo': 'arrival_datetime vs departure_datetime',
                    'departure': departure.isoformat(),
                    'arrival': arrival.isoformat(),
                    'problema': f"Viaje {trip_id}: llegada ({arrival}) antes que salida ({departure})",
                    'severidad': 'ALTA'
                })
            
            # 2. Fechas futuras en viajes (imposibles)
            cursor.execute("""
                SELECT trip_id, departure_datetime
                FROM trips
                WHERE departure_datetime > NOW()
            """)
            future_trips = cursor.fetchall()
            
            for trip_id, departure in future_trips:
                temporal_errors.append({
                    'tabla': 'trips',
                    'registro_id': trip_id,
                    'campo': 'departure_datetime',
                    'departure': departure.isoformat(),
                    'problema': f"Viaje {trip_id}: fecha de salida en el futuro ({departure})",
                    'severidad': 'MEDIA'
                })
            
            # 3. Mantenimientos con fechas imposibles
            cursor.execute("""
                SELECT maintenance_id, maintenance_date, next_maintenance_date
                FROM maintenance
                WHERE next_maintenance_date IS NOT NULL
                AND next_maintenance_date <= maintenance_date
            """)
            invalid_maintenance = cursor.fetchall()
            
            for maint_id, maint_date, next_date in invalid_maintenance:
                temporal_errors.append({
                    'tabla': 'maintenance',
                    'registro_id': maint_id,
                    'campo': 'next_maintenance_date vs maintenance_date',
                    'maintenance_date': maint_date.isoformat(),
                    'next_maintenance_date': next_date.isoformat(),
                    'problema': f"Mantenimiento {maint_id}: próxima fecha ({next_date}) antes que fecha actual ({maint_date})",
                    'severidad': 'ALTA'
                })
            
            # 4. Mantenimientos muy antiguos (más de 10 años)
            cursor.execute("""
                SELECT maintenance_id, maintenance_date
                FROM maintenance
                WHERE maintenance_date < NOW() - INTERVAL '10 years'
            """)
            old_maintenance = cursor.fetchall()
            
            for maint_id, maint_date in old_maintenance:
                temporal_errors.append({
                    'tabla': 'maintenance',
                    'registro_id': maint_id,
                    'campo': 'maintenance_date',
                    'maintenance_date': maint_date.isoformat(),
                    'problema': f"Mantenimiento {maint_id}: fecha muy antigua ({maint_date}) - más de 10 años",
                    'severidad': 'BAJA'
                })
            
            self.analysis_results['temporal_inconsistencies'] = temporal_errors
            logger.info(f"Encontradas {len(temporal_errors)} inconsistencias temporales")
            
            # Log por severidad
            alta = len([e for e in temporal_errors if e['severidad'] == 'ALTA'])
            media = len([e for e in temporal_errors if e['severidad'] == 'MEDIA'])
            baja = len([e for e in temporal_errors if e['severidad'] == 'BAJA'])
            
            if alta > 0:
                logger.error(f"  SEVERIDAD ALTA: {alta} problemas críticos")
            if media > 0:
                logger.warning(f"  SEVERIDAD MEDIA: {media} problemas moderados")
            if baja > 0:
                logger.info(f"  SEVERIDAD BAJA: {baja} problemas menores")
                
        except Exception as e:
            logger.error(f"Error analizando fechas: {e}")
        finally:
            cursor.close()
    
    def analyze_logical_errors(self):
        """
        Detecta errores lógicos y duplicados.
        """
        logger.info("ANALIZANDO ERRORES LÓGICOS Y DUPLICADOS...")
        
        cursor = self.connection.cursor()
        logical_errors = []
        
        try:
            # 1. Conductores con códigos de empleado duplicados
            cursor.execute("""
                SELECT employee_code, COUNT(*) as cnt
                FROM drivers
                GROUP BY employee_code
                HAVING COUNT(*) > 1
            """)
            duplicate_codes = cursor.fetchall()
            
            for emp_code, count in duplicate_codes:
                cursor.execute("SELECT driver_id FROM drivers WHERE employee_code = %s", (emp_code,))
                driver_ids = [row[0] for row in cursor.fetchall()]
                
                logical_errors.append({
                    'tabla': 'drivers',
                    'campo': 'employee_code',
                    'valor': emp_code,
                    'registros_afectados': driver_ids,
                    'problema': f"Código empleado duplicado '{emp_code}' en {count} conductores: {driver_ids}",
                    'severidad': 'ALTA'
                })
            
            # 2. Vehículos con múltiples viajes simultáneos
            cursor.execute("""
                SELECT t1.vehicle_id, t1.trip_id, t2.trip_id,
                       t1.departure_datetime, t1.arrival_datetime,
                       t2.departure_datetime, t2.arrival_datetime
                FROM trips t1
                JOIN trips t2 ON t1.vehicle_id = t2.vehicle_id AND t1.trip_id != t2.trip_id
                WHERE t1.arrival_datetime IS NOT NULL AND t2.arrival_datetime IS NOT NULL
                AND (
                    (t1.departure_datetime BETWEEN t2.departure_datetime AND t2.arrival_datetime)
                    OR (t1.arrival_datetime BETWEEN t2.departure_datetime AND t2.arrival_datetime)
                    OR (t2.departure_datetime BETWEEN t1.departure_datetime AND t1.arrival_datetime)
                    OR (t2.arrival_datetime BETWEEN t1.departure_datetime AND t1.arrival_datetime)
                )
            """)
            overlapping_trips = cursor.fetchall()
            
            for vehicle_id, trip1, trip2, dep1, arr1, dep2, arr2 in overlapping_trips:
                logical_errors.append({
                    'tabla': 'trips',
                    'campo': 'vehicle_id + fechas',
                    'valor': vehicle_id,
                    'registros_afectados': [trip1, trip2],
                    'problema': f"Vehículo {vehicle_id}: viajes {trip1} y {trip2} se superponen temporalmente",
                    'detalles': f"Viaje {trip1}: {dep1} - {arr1}, Viaje {trip2}: {dep2} - {arr2}",
                    'severidad': 'ALTA'
                })
            
            # 3. Entregas sin dirección válida
            cursor.execute("""
                SELECT delivery_id, delivery_address
                FROM deliveries
                WHERE delivery_address IS NULL 
                   OR delivery_address = ''
                   OR LENGTH(delivery_address) < 5
            """)
            invalid_addresses = cursor.fetchall()
            
            for delivery_id, address in invalid_addresses:
                logical_errors.append({
                    'tabla': 'deliveries',
                    'campo': 'delivery_address',
                    'valor': address,
                    'registros_afectados': [delivery_id],
                    'problema': f"Entrega {delivery_id}: dirección inválida o vacía '{address}'",
                    'severidad': 'MEDIA'
                })
            
            # 4. Vehículos sin mantenimiento reciente (más de 2 años)
            cursor.execute("""
                SELECT v.vehicle_id, v.license_plate, MAX(m.maintenance_date) as ultimo_mantenimiento
                FROM vehicles v
                LEFT JOIN maintenance m ON v.vehicle_id = m.vehicle_id
                GROUP BY v.vehicle_id, v.license_plate
                HAVING MAX(m.maintenance_date) IS NULL 
                    OR MAX(m.maintenance_date) < NOW() - INTERVAL '2 years'
            """)
            no_maintenance = cursor.fetchall()
            
            for vehicle_id, license_plate, last_maint in no_maintenance:
                logical_errors.append({
                    'tabla': 'vehicles',
                    'campo': 'maintenance_date',
                    'valor': str(last_maint) if last_maint else 'NULL',
                    'registros_afectados': [vehicle_id],
                    'problema': f"Vehículo {vehicle_id} ({license_plate}): sin mantenimiento reciente (último: {last_maint})",
                    'severidad': 'BAJA'
                })
            
            self.analysis_results['logical_errors'] = logical_errors
            logger.info(f"Encontrados {len(logical_errors)} errores lógicos")
            
            # Log por tipo
            duplicados = len([e for e in logical_errors if 'duplicado' in e['problema']])
            superposiciones = len([e for e in logical_errors if 'superponen' in e['problema']])
            direcciones = len([e for e in logical_errors if 'dirección' in e['problema']])
            mantenimiento = len([e for e in logical_errors if 'mantenimiento' in e['problema']])
            
            if duplicados > 0:
                logger.warning(f"  Duplicados: {duplicados}")
            if superposiciones > 0:
                logger.error(f"  Superposiciones temporales: {superposiciones}")
            if direcciones > 0:
                logger.warning(f"  Direcciones inválidas: {direcciones}")
            if mantenimiento > 0:
                logger.info(f"  Sin mantenimiento reciente: {mantenimiento}")
                
        except Exception as e:
            logger.error(f"Error analizando lógica: {e}")
        finally:
            cursor.close()
    
    def generate_summary_report(self):
        """
        Genera un resumen consolidado de todos los problemas encontrados.
        """
        logger.info("GENERANDO REPORTE CONSOLIDADO...")
        
        total_issues = (
            len(self.analysis_results['gender_inconsistencies']) +
            len(self.analysis_results['referential_integrity_errors']) +
            len(self.analysis_results['temporal_inconsistencies']) +
            len(self.analysis_results['logical_errors'])
        )
        
        # Contar por severidad
        alta_count = 0
        media_count = 0
        baja_count = 0
        
        for category in ['referential_integrity_errors', 'temporal_inconsistencies', 'logical_errors', 'gender_inconsistencies']:
            for issue in self.analysis_results[category]:
                if issue.get('severidad') == 'ALTA':
                    alta_count += 1
                elif issue.get('severidad') == 'MEDIA':
                    media_count += 1
                elif issue.get('severidad') == 'BAJA':
                    baja_count += 1
        
        summary = {
            'total_issues': total_issues,
            'severity_breakdown': {
                'alta': alta_count,
                'media': media_count,
                'baja': baja_count
            },
            'category_breakdown': {
                'gender_inconsistencies': len(self.analysis_results['gender_inconsistencies']),
                'referential_integrity_errors': len(self.analysis_results['referential_integrity_errors']),
                'temporal_inconsistencies': len(self.analysis_results['temporal_inconsistencies']),
                'logical_errors': len(self.analysis_results['logical_errors'])
            },
            'data_quality_score': max(0, 100 - (alta_count * 10 + media_count * 5 + baja_count * 1)),
            'recommendations': []
        }
        
        # Agregar recomendaciones
        if alta_count > 0:
            summary['recommendations'].append("CRÍTICO: Corregir problemas de severidad ALTA inmediatamente")
        if media_count > 0:
            summary['recommendations'].append("IMPORTANTE: Revisar y corregir problemas de severidad MEDIA")
        if baja_count > 0:
            summary['recommendations'].append("OPCIONAL: Considerar corrección de problemas menores")
        
        if total_issues == 0:
            summary['recommendations'].append("EXCELENTE: No se encontraron problemas de coherencia")
        
        self.analysis_results['summary'] = summary
        
        # Log del resumen
        logger.info("="*60)
        logger.info("RESUMEN DE ANÁLISIS DE COHERENCIA")
        logger.info("="*60)
        logger.info(f"Total de problemas encontrados: {total_issues}")
        logger.info(f"  Severidad ALTA:   {alta_count}")
        logger.info(f"  Severidad MEDIA:  {media_count}")
        logger.info(f"  Severidad BAJA:   {baja_count}")
        logger.info(f"Puntuación de calidad de datos: {summary['data_quality_score']}/100")
        logger.info("="*60)
        
        for rec in summary['recommendations']:
            if 'CRÍTICO' in rec:
                logger.error(f"CRITICO: {rec}")
            elif 'IMPORTANTE' in rec:
                logger.warning(f"IMPORTANTE: {rec}")
            elif 'OPCIONAL' in rec:
                logger.info(f"OPCIONAL: {rec}")
            else:
                logger.info(f"OK: {rec}")
    
    def save_report(self):
        """Guarda el reporte completo en archivo JSON."""
        filename = f"data_coherence_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(self.analysis_results, f, indent=2, ensure_ascii=False, default=str)
            
            logger.info(f"Reporte guardado en: {filename}")
            return filename
        except Exception as e:
            logger.error(f"Error guardando reporte: {e}")
            return None
    
    def run_analysis(self):
        """Ejecuta el análisis completo de coherencia."""
        logger.info("INICIANDO ANÁLISIS COMPLETO DE COHERENCIA DE DATOS")
        logger.info("="*60)
        
        try:
            # Ejecutar todos los análisis
            self.analyze_gender_inconsistencies()
            self.analyze_gender_distribution()  # NUEVA función para detectar mezcla
            self.analyze_referential_integrity()
            self.analyze_temporal_inconsistencies()
            self.analyze_logical_errors()
            self.generate_summary_report()
            
            # Guardar reporte
            report_file = self.save_report()
            
            logger.info("ANÁLISIS COMPLETADO EXITOSAMENTE")
            return True, report_file
            
        except Exception as e:
            logger.error(f"Error durante el análisis: {e}")
            return False, None
        finally:
            if self.connection:
                self.connection.close()
                logger.info("Conexión cerrada")

def main():
    """Función principal."""
    print("="*60)
    print("ANALIZADOR DE COHERENCIA DE DATOS - FLEETLOGIX")
    print("="*60)
    
    analyzer = DataCoherenceAnalyzer()
    success, report_file = analyzer.run_analysis()
    
    if success:
        print(f"\nEXITO: ANÁLISIS COMPLETADO EXITOSAMENTE")
        if report_file:
            print(f"Reporte guardado en: {report_file}")
        print("Revisa los logs para detalles completos")
    else:
        print(f"\nERROR DURANTE EL ANÁLISIS")
        print("Revisa los logs para más información")
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())