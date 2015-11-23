#include "mruby.h"
#include "mruby/proc.h"
#include "mruby/data.h"
#include "mruby/compile.h"
#include "mruby/string.h"
#include "mruby/numeric.h"
#include <math.h>
#include <stdlib.h>
#include "mruby/object.h"

mrb_state *mrb;
mrb_irep *irep_irq;
struct RProc *proc_irq;

// void TIM2_IRQHandler ( void )
// {
// }

int main( void )
{
    mrb = mrb_open();
	if (mrb == NULL) {
		return 0;
	}

	#include "main_rb.h"	//Ruby code
	char retString[256];

	mrb_value return_value1;
	return_value1 = mrb_load_irep(mrb, code);
	if(mrb->exc){
		 if(!mrb_undef_p(return_value1)){
		     mrb_value s = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
		     if (mrb_string_p(s)) {
		    	 //err
		    	 sprintf(retString, RSTRING_PTR(s));
		     } else {
		     }
		     return 0;
		 }
    }

    mrb_close(mrb);

    return(0);
}
