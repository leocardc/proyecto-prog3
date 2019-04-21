'use strict';

// se crea un nuevo objeto anónimo a partir de una clase anónima
// dicho objeto define la gestión de clientes, utilizando el componente 'Tabulator' (http://tabulator.info/)

new class Proveedor {

    constructor() {

        this.contenedor = '#tabla-proveedores'; // el div que contendrá la tabla de datos de clientes
        this.filasPorPagina = 15;

        this.parametros = { // parámetros que se envían al servidor para mostrar la tabla
            clase: 'Proveedor',
            accion: 'seleccionar'
        };

        this.columnas = [ // este array de objetos define las columnas de la tabla

            { title: 'ID Proveedor', field: 'id_proveedor', width: 100 },
            { title: 'Nombre', field: 'nombre', width: 270 },
            { title: 'Telefono', field: 'telefono' },
            { title: 'Correo', field: 'correo' },

        ];

        this.ordenInicial = [ // establece el orden inicial de los datos
            { column: 'nombre', dir: 'asc' }
        ]

        this.indice = 'id_proveedor'; // estable la PK como índice único para cada fila de la tabla visualizada
        this.tabla = this.generarTabla();
        this.filaActual; // guarda el objeto "fila actual" cuando se elige actualizar o eliminar sobre una fila
        this.operacion; // insertar | actualizar | eliminar

        this.frmEdicionProveedor = M.Modal.init($('#proveedor-frmedicion'), {
            dismissible: false // impedir el acceso a la aplicación durante la edición
        });

    }

    generarTabla() {
        return new Tabulator(this.contenedor, {
            ajaxURL: util.URL_APP,
            ajaxParams: this.parametros,
            ajaxConfig: 'POST', // tipo de solicitud HTTP ajax
            ajaxContentType: 'json', // enviar parámetros al servidor como una cadena JSON
            layout: 'fitColumns', // ajustar columnas al ancho de la tabla
            responsiveLayout: 'hide', // ocultar columnas que no caben en el espacio de trabajola tabla
            tooltips: true, // mostrar mensajes sobre las celdas.
            addRowPos: 'top', // al agregar una nueva fila, agréguela en la parte superior de la tabla
            history: true, // permite deshacer y rehacer acciones sobre la tabla.
            pagination: 'local', // cómo paginar los datos
            paginationSize: this.filasPorPagina,
            movableColumns: true, // permitir cambiar el orden de las columnas
            resizableRows: true, // permitir cambiar el orden de las filas
            initialSort: this.ordenInicial,
            columns: this.columnas,
            // addRowPos: 'top', // no se usa aquí. Aquí se usa un formulario de edición personalizado
            index: this.indice, // indice único de cada fila
            // locale: true, // se supone que debería utilizar el idioma local
            rowAdded: (row) => this.filaActual = row
        });
    }

}